
#include studio
const vec3 CAM_POS=vec3(2.9,2.35,4.4);
const vec3 CAM_TGT=vec3(0.1,0.5,0.05);
const float FOCAL=4.1;

float gableSolid(vec3 q, float w, float d, float he, float hr){
  float b=sdBox(q-vec3(0.,hr*0.5,0.), vec3(w,hr*0.5,d));
  vec3 rp=vec3(0.,hr,0.);
  vec3 nl=normalize(vec3(-(hr-he),w,0.)), nr=normalize(vec3(hr-he,w,0.));
  return max(b,max(dot(q-rp,nl),dot(q-rp,nr)));
}
const float W=0.55, D=0.5, HE=0.78, HR=1.32;
float roof(vec3 q){
  q.x=abs(q.x);
  float a=atan(HR-HE,W), c=cos(a), s=sin(a);
  vec2 nR=normalize(vec2(HR-HE,W));
  vec2 v=q.xy-(vec2(0.,HR)+nR*0.03);
  vec2 l=vec2(v.x*c-v.y*s, v.x*s+v.y*c);
  float L=length(vec2(W,HR-HE))+0.1;
  return sdRBox(vec3(l.x-(L-0.05)*0.5, l.y, q.z), vec3((L+0.05)*0.5,0.03,D+0.08),0.01);
}
float coinStack(vec3 p, float n){
  float h=0.052; float i=clamp(floor(p.y/h),0.,n-1.);
  vec3 q=p; q.y-=(i+0.5)*h;
  float o=hash12(vec2(i,n*3.1))*6.283; q.xz-=vec2(cos(o),sin(o))*0.014;
  return sdRCylY(q,0.21,0.024,0.009);
}
vec2 map(vec3 p){
  // домик
  vec3 q=p-vec3(-0.55,0.,-0.1);
  vec2 res=vec2(1e9,0.);
  float bh=sdBox(q-vec3(0.,0.7,0.),vec3(0.75,0.8,0.7));
  if(bh<0.3){
    float w=gableSolid(q,W,D,HE,HR);
    w=smax(w,-1e9,0.);
    // окна и дверь
    float win=min(sdBox(q-vec3(-0.27,0.48,D),vec3(0.12,0.14,0.03)), sdBox(q-vec3(0.27,0.48,D),vec3(0.12,0.14,0.03)));
    win=min(win, sdBox(q-vec3(0.,1.0,D),vec3(0.08,0.1,0.03)));
    float door=sdBox(q-vec3(0.,0.2,D),vec3(0.1,0.2,0.03));
    float sidew=sdBox(q-vec3(W,0.45,0.),vec3(0.03,0.14,0.2));
    w=max(w,-min(min(win,door),sidew));
    res=opU(res,vec2(w,1.));
    res=opU(res,vec2(min(sdBox(q-vec3(-0.27,0.48,D-0.02),vec3(0.12,0.14,0.01)),min(sdBox(q-vec3(0.27,0.48,D-0.02),vec3(0.12,0.14,0.01)),min(sdBox(q-vec3(0.,1.0,D-0.02),vec3(0.08,0.1,0.01)),sdBox(q-vec3(W-0.02,0.45,0.),vec3(0.01,0.14,0.2))))),3.));
    res=opU(res,vec2(sdBox(q-vec3(0.,0.2,D-0.015),vec3(0.1,0.2,0.012)),4.));
    res=opU(res,vec2(roof(q),2.));
    res=opU(res,vec2(sdRBox(q-vec3(0.28,1.25,-0.15),vec3(0.06,0.2,0.06),0.01),5.));
    res=opU(res,vec2(sdRBox(q-vec3(0.,0.025,0.),vec3(W+0.04,0.025,D+0.04),0.008),5.));
  } else res=vec2(bh,1.);
  // стопки монет
  res=opU(res,vec2(coinStack(p-vec3(0.62,0.,0.32),7.),6.));
  res=opU(res,vec2(coinStack(p-vec3(1.0,0.,-0.12),11.),6.));
  res=opU(res,vec2(coinStack(p-vec3(0.48,0.,-0.28),4.),6.));
  vec3 cq=p-vec3(1.12,0.,0.55); cq.xy*=rot(0.);
  res=opU(res,vec2(sdRCylY(cq-vec3(0.,0.024,0.),0.21,0.024,0.009),6.));
  // ключ
  vec3 k=p-vec3(-0.25,0.026,0.78); k.xz*=rot(-0.45);
  float key=sdTorus(k,vec2(0.11,0.026));
  key=min(key,sdRBox(k-vec3(0.33,0.,0.),vec3(0.21,0.02,0.024),0.008));
  key=min(key,sdRBox(k-vec3(0.46,0.,0.055),vec3(0.025,0.018,0.04),0.006));
  key=min(key,sdRBox(k-vec3(0.39,0.,0.045),vec3(0.02,0.018,0.03),0.006));
  key=min(key,sdRBox(k-vec3(0.13,0.,0.),vec3(0.03,0.028,0.035),0.01));
  res=opU(res,vec2(key,7.));
  return res;
}
Mat getMat(float id, vec3 p, vec3 n){
  if(id<1.5){ vec3 q=p-vec3(-0.55,0.,-0.1); Mat m=M(vec3(0.90,0.885,0.86)*(0.96+0.06*noise3(p*40.)),0.75,0.,0.4); return m; }
  if(id<2.5){ vec3 q=p-vec3(-0.55,0.,-0.1); float seam=1.-smoothstep(0.004,0.01,abs(fract(q.z/0.12)-0.5)); return M(vec3(0.07,0.072,0.078)+seam*0.05,0.38,0.5,0.5); }
  if(id<3.5){ Mat m=M(vec3(0.015,0.02,0.025),0.04,0.,1.6); m.emi=vec3(1.,0.72,0.45)*0.035; return m; }
  if(id<4.5){ float g=noise3(vec3(p.x*30.,p.y*3.,p.z*30.)); return M(vec3(0.45,0.30,0.18)*(0.8+0.3*g),0.55,0.,0.5); }
  if(id<5.5){ return M(vec3(0.55,0.54,0.52),0.75,0.,0.4); }
  if(id<6.5){ float g=noise3(p*60.); return M(vec3(0.96,0.80,0.48)*(0.95+0.08*g),0.24,1.,0.5); }
  return M(vec3(0.93,0.77,0.45),0.2,1.,0.5);
}
