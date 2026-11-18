
// ── raymarch / lighting (shared) ──
#ifndef MAXSTEPS
#define MAXSTEPS 220
#endif
#ifndef TMAX
#define TMAX 60.
#endif
#ifndef STEPK
#define STEPK 0.85
#endif

vec2 march(vec3 ro, vec3 rd){
  float t=0.02; float m=-1.;
  for(int i=0;i<MAXSTEPS;i++){
    vec2 h=map(ro+rd*t);
    if(h.x<0.0003*t+0.0002){ m=h.y; break; }
    t+=h.x*STEPK;
    if(t>TMAX) break;
  }
  return vec2(t, m);
}
vec3 calcN(vec3 p){
  const float e=0.0008; vec2 k=vec2(1,-1);
  return normalize(k.xyy*map(p+k.xyy*e).x + k.yyx*map(p+k.yyx*e).x + k.yxy*map(p+k.yxy*e).x + k.xxx*map(p+k.xxx*e).x);
}
float softShadow(vec3 ro, vec3 rd, float tmin, float tmax, float k){
  float res=1., t=tmin;
  for(int i=0;i<80;i++){
    float h=map(ro+rd*t).x;
    res=min(res,k*h/t);
    t+=clamp(h,0.01,0.35);
    if(res<0.001||t>tmax) break;
  }
  res=clamp(res,0.,1.); return res*res*(3.-2.*res);
}
float calcAO(vec3 p, vec3 n){
  float occ=0., sca=1.;
  for(int i=0;i<6;i++){ float h=0.012+0.11*float(i)/5.; float d=map(p+n*h).x; occ+=(h-d)*sca; sca*=0.82; }
  return clamp(1.-2.2*occ,0.,1.);
}
float calcAOwide(vec3 p, vec3 n){
  float occ=0., sca=1.;
  for(int i=0;i<5;i++){ float h=0.05+0.5*float(i)/4.; float d=map(p+n*h).x; occ+=(h-d)*sca; sca*=0.7; }
  return clamp(1.-0.9*occ,0.,1.);
}

vec3 envMap(vec3 d, float rough){
  float y=d.y;
  vec3 sky=mix(HORIZON_COL, ZENITH_COL, smoothstep(-0.02,0.7,y));
  vec3 gnd=mix(HORIZON_COL*0.75, GROUND_ENV, smoothstep(0.,-0.4,y));
  vec3 c = y>0. ? sky : gnd;
  // soft boxes
  float sb=max(dot(d,normalize(SUN_DIR)),0.);
  c += SUN_COL*0.25*pow(sb, mix(220.,6.,rough));
  float sb2=max(dot(d,normalize(vec3(0.7,0.35,-0.6))),0.);
  c += vec3(1.)*0.35*pow(sb2, mix(60.,4.,rough));
  return c;
}

vec3 aces(vec3 x){ return clamp((x*(2.51*x+0.03))/(x*(2.43*x+0.59)+0.14),0.,1.); }

vec4 render(vec3 ro, vec3 rd){
  vec2 h=march(ro,rd);
  float tg = rd.y<0. ? (GROUND_Y-ro.y)/rd.y : 1e9;
  if(h.y<0. || h.x>TMAX || (tg<h.x)){
    // background / shadow catcher
    if(tg<1e8 && tg<TMAX){
      vec3 gp=ro+rd*tg;
      float sh=softShadow(gp+vec3(0,0.002,0), SUN_DIR, 0.02, 25., 6.);
      float ao=calcAOwide(gp, vec3(0,1,0));
      float fall=exp(-0.02*dot(gp.xz-SHADOW_CENTER,gp.xz-SHADOW_CENTER));
      float a=clamp((1.-sh)*0.42*fall + (1.-ao)*0.75, 0., 0.85);
      return vec4(SHADOW_TINT, a);
    }
#ifdef OPAQUE_BG
    return vec4(envMap(rd,0.)*1.6,1.);
#endif
    return vec4(0.);
  }
  vec3 p=ro+rd*h.x;
  vec3 n=calcN(p);
  Mat m=getMat(h.y,p,n);
#ifdef SRGB_ALB
  m.alb=pow(m.alb,vec3(2.2));
#endif
  float occ=calcAO(p,n)*mix(1.,calcAOwide(p,n),0.6);
  vec3 L=normalize(SUN_DIR);
  float dif=clamp(dot(n,L),0.,1.);
  float sha= dif>0.001 ? softShadow(p+n*0.003, L, 0.015, 25., SHADOW_K) : 0.;
  vec3 V=-rd; vec3 H=normalize(L+V);
  float nv=clamp(dot(n,V),0.001,1.), nh=clamp(dot(n,H),0.,1.), vh=clamp(dot(V,H),0.,1.);
  float a=max(m.rough*m.rough,0.002), a2=a*a;
  float dd=nh*nh*(a2-1.)+1.; float D=a2/(PI*dd*dd);
  vec3 F0=mix(vec3(0.04*m.spec*2.), m.alb, m.metal);
  vec3 F=F0+(1.-F0)*pow(1.-vh,5.);
  float k=(m.rough+1.)*(m.rough+1.)/8.;
  float G=(nv/(nv*(1.-k)+k))*(dif/(dif*(1.-k)+k+1e-4));
  vec3 kd=(1.-F)*(1.-m.metal);

  vec3 col=vec3(0.);
  col += kd*m.alb*SUN_COL*dif*sha;
  col += SUN_COL*D*F*G/max(4.*nv*dif,1e-3)*dif*sha;
  float skyd=0.5+0.5*n.y;
  col += kd*m.alb*SKY_COL*skyd*occ;
  col += kd*m.alb*BOUNCE_COL*clamp(0.5-0.5*n.y,0.,1.)*occ;
  vec3 Lb=normalize(vec3(-L.x,0.25,-L.z));
  col += kd*m.alb*BACK_COL*clamp(dot(n,Lb),0.,1.)*occ;
  // environment specular
  vec3 r=reflect(rd,n);
  float fre=pow(1.-nv,5.);
  vec3 Fe=F0+(max(vec3(1.-m.rough),F0)-F0)*fre;
  float specOcc = occ;
  if(m.rough<0.3) specOcc*=mix(1.,softShadow(p+n*0.004, r, 0.02, 8., 4.), 1.-m.rough);
  col += envMap(r,m.rough)*Fe*specOcc*ENV_STRENGTH;
  col += m.emi;
  return vec4(col,1.);
}

void main(){
  vec2 fc=gl_FragCoord.xy;
  vec3 ro=CAM_POS;
  vec3 ww=normalize(CAM_TGT-ro), uu=normalize(cross(ww,vec3(0,1,0))), vv=cross(uu,ww);
  vec3 acc=vec3(0.); float accA=0.;
  int N=uSpp;
  for(int j=0;j<N;j++) for(int i=0;i<N;i++){
    vec2 o=(vec2(float(i),float(j))+0.5)/float(N)-0.5;
    o+= (vec2(hash12(fc+float(i*7+j)), hash12(fc.yx+float(j*13+i)))-0.5)/float(N)*0.8;
    vec2 uv=(2.*(fc+o)-uRes)/uRes.y;
    vec3 rd=normalize(uv.x*uu+uv.y*vv+FOCAL*ww);
    vec4 c=render(ro,rd);
    vec3 cc=aces(c.rgb*EXPOSURE);
    acc+=cc*c.a; accA+=c.a;
  }
  float A=accA/float(N*N);
  vec3 C= accA>0. ? acc/accA : vec3(0.);
  C=pow(C,vec3(1./2.2));
  C+= (hash12(fc*1.7)-0.5)/255.;
  outColor=vec4(C,A);
}
