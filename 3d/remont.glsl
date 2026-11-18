
#include studio
const vec3 CAM_POS=vec3(2.7,2.5,4.5);
const vec3 CAM_TGT=vec3(0.15,0.36,0.05);
const float FOCAL=4.4;

const vec3 CAN=vec3(-0.5,0.,-0.05);
const vec3 D1=normalize(vec3(1.,0.,-0.55));
const vec3 D2=normalize(vec3(0.55,0.,1.));
const vec3 RC=vec3(0.42,0.11,0.52);

float brick(vec3 p, vec3 c, float a){ vec3 q=p-c; q.xz*=rot(a); return sdRBox(q,vec3(0.25,0.065,0.12),0.014); }

vec2 map(vec3 p){
  vec2 res=vec2(1e9,0.);
  // банка
  vec3 c=p-CAN;
  float bc=sdCylY(c-vec3(0.,0.5,0.),0.52,0.62);
  if(bc<0.3){
    float outer=sdRCylY(c-vec3(0.,0.47,0.),0.42,0.47,0.01);
    float inner=sdCylY(c-vec3(0.,0.6,0.),0.395,0.5);
    float can=max(outer,-inner);
    can=min(can,sdTorus(c-vec3(0.,0.935,0.),vec2(0.41,0.022)));
    can=min(can,sdTorus(c-vec3(0.,0.04,0.),vec2(0.415,0.014)));
    can=min(can,sdTorus(c-vec3(0.,0.3,0.),vec2(0.42,0.007)));
    can=min(can,sdTorus(c-vec3(0.,0.68,0.),vec2(0.42,0.007)));
    res=opU(res,vec2(can,1.));
    // краска внутри и потёк
    float paint=sdCylY(c-vec3(0.,0.62,0.),0.396,0.24);
    vec3 dp=c-vec3(0.29,0.,0.29);
    float drip=sdCap(dp,vec3(0.,0.93,0.),vec3(0.,0.74,0.),0.022);
    drip=smin(drip,sdSph(dp-vec3(0.,0.73,0.),0.03),0.03);
    float ddir=length(c.xz)-0.425;
    drip=max(drip, -ddir-0.0);
    paint=min(paint,drip);
    paint=min(paint,sdTorus(c-vec3(0.,0.95,0.),vec2(0.41,0.012)) - 0.004*step(0.,c.x+c.z));
    res=opU(res,vec2(paint,2.));
    // дужка
    vec3 h=c-vec3(0.,0.82,0.); h.yz*=rot(1.15);
    float hd=sdTorus(h.xzy,vec2(0.43,0.011)); hd=max(hd,-h.y);
    res=opU(res,vec2(hd,3.));
  } else res=vec2(bc,1.);
  // валик
  vec3 r=p-RC;
  float br=sdSph(r-D2*0.35,0.95);
  if(br<0.3){
    float ax=dot(r,D1); vec3 rr=r-D1*ax;
    float sleeve=max(length(rr)-0.11, abs(ax)-0.3);
    sleeve=smax(sleeve, abs(ax)-0.29,0.03);
    res=opU(res,vec2(sleeve,4.));
    vec3 e=RC+D1*0.33; vec3 e2=e+D1*0.05; vec3 e3=e2+D2*0.3+vec3(0.,0.06,0.);
    float wire=min(sdCap(p,RC+D1*0.29,e2,0.012), sdCap(p,e2,e3,0.013));
    res=opU(res,vec2(wire,3.));
    float handle=sdCap(p,e3,e3+D2*0.42+vec3(0.,0.05,0.),0.042);
    handle=smin(handle,sdCap(p,e3,e3+D2*0.06,0.05),0.02);
    res=opU(res,vec2(handle,5.));
  } else res=opU(res,vec2(br,4.));
  // кирпичи
  float bb=sdSph(p-vec3(0.85,0.15,-0.45),0.7);
  if(bb<0.3){
    float b=brick(p,vec3(0.85,0.065,-0.32),0.08);
    b=min(b,brick(p,vec3(0.82,0.065,-0.59),0.03));
    b=min(b,brick(p,vec3(0.85,0.196,-0.46),1.52));
    res=opU(res,vec2(b,6.));
  } else res=opU(res,vec2(bb,6.));
  return res;
}
Mat getMat(float id, vec3 p, vec3 n){
  if(id<1.5){
    vec3 c=p-CAN;
    Mat m=M(vec3(0.80,0.81,0.82),0.3,1.,0.5);
    if(c.y>0.16&&c.y<0.62&&length(c.xz)>0.405){
      float ang=atan(c.z,c.x);
      m=M(vec3(0.16,0.36,0.27),0.45,0.,0.5);
      if(c.y>0.33&&c.y<0.47) m=M(vec3(0.93,0.91,0.86),0.5,0.,0.4);
      if(c.y>0.37&&c.y<0.43&&abs(ang-0.75)<0.35) m=M(vec3(0.16,0.36,0.27),0.5,0.,0.4);
    }
    return m;
  }
  if(id<2.5) return M(vec3(0.28,0.47,0.36),0.12,0.,0.6);
  if(id<3.5) return M(vec3(0.75,0.76,0.78),0.25,1.,0.5);
  if(id<4.5){ float f=noise3(p*90.); return M(vec3(0.28,0.47,0.36)*(0.85+0.3*f),0.9,0.,0.2); }
  if(id<5.5) return M(vec3(0.05,0.055,0.06),0.4,0.,0.5);
  float g=noise3(p*25.), sp=step(0.82,hash13(floor(p*120.)));
  return M(mix(vec3(0.42,0.15,0.08),vec3(0.52,0.21,0.11),g)*(1.-0.3*sp),0.85,0.,0.3);
}
