
#include studio
const vec3 CAM_POS=vec3(2.6,2.3,4.6);
const vec3 CAM_TGT=vec3(0.0,0.48,0.0);
const float FOCAL=4.4;

const vec3 RAD=vec3(0.1,0.,-0.45);
const vec3 TAP=vec3(-0.78,0.,0.3);
const vec3 PL=vec3(0.62,0.,0.48);
const vec3 PD=normalize(vec3(-1.,0.,0.55));

vec2 map(vec3 p){
  vec2 res=vec2(1e9,0.);
  // радиатор
  vec3 r=p-RAD;
  float br=sdBox(r-vec3(0.,0.6,0.),vec3(0.75,0.65,0.3));
  if(br<0.3){
    float sx=0.12; float i=clamp(floor(r.x/sx+0.5),-5.,5.);
    vec3 q=r; q.x-=i*sx;
    float col=min(sdCap(q,vec3(0.,0.16,0.055),vec3(0.,1.02,0.055),0.03), sdCap(q,vec3(0.,0.16,-0.055),vec3(0.,1.02,-0.055),0.03));
    float man=min(sdCap(r,vec3(-0.62,0.14,0.),vec3(0.62,0.14,0.),0.045), sdCap(r,vec3(-0.62,1.04,0.),vec3(0.62,1.04,0.),0.045));
    float legs=min(sdCap(r,vec3(-0.5,0.,0.),vec3(-0.5,0.14,0.),0.03), sdCap(r,vec3(0.5,0.,0.),vec3(0.5,0.14,0.),0.03));
    float rad=smin(min(col,legs),man,0.03);
    res=opU(res,vec2(rad,1.));
    // вентиль
    float v=sdCap(r,vec3(0.62,1.04,0.),vec3(0.72,1.04,0.),0.035);
    res=opU(res,vec2(v,2.));
    res=opU(res,vec2(sdRCylY((r-vec3(0.76,1.04,0.)).yxz,0.055,0.04,0.015),3.));
  } else res=vec2(br,1.);
  // смеситель
  vec3 t=p-TAP;
  float bt=sdBox(t-vec3(0.1,0.4,0.),vec3(0.4,0.45,0.25));
  if(bt<0.3){
    float base=sdRCylY(t-vec3(0.,0.015,0.),0.15,0.015,0.008);
    float body=sdRCylY(t-vec3(0.,0.3,0.),0.055,0.28,0.02);
    vec3 a=t-vec3(0.17,0.58,0.);
    float arc=sdTorus(a.xzy,vec2(0.17,0.032)); arc=max(arc,-a.y);
    float outl=sdRCylY(t-vec3(0.34,0.55,0.),0.034,0.04,0.012);
    float lever=sdCap(t,vec3(-0.02,0.45,0.),vec3(-0.15,0.53,0.),0.02);
    lever=smin(lever,sdRCylY(t-vec3(0.,0.45,0.),0.06,0.03,0.015),0.02);
    float tap=smin(min(min(base,body),min(arc,outl)),lever,0.02);
    res=opU(res,vec2(tap,2.));
  } else res=opU(res,vec2(bt,2.));
  // вилка с кабелем
  vec3 l=p-PL;
  float bl=sdSph(l-vec3(0.,0.1,0.),0.75);
  if(bl<0.3){
    float ax=dot(l-vec3(0.,0.105,0.),PD); vec3 rr=(l-vec3(0.,0.105,0.))-PD*ax;
    float body=max(length(rr)-0.1, abs(ax-0.0)-0.12); body=smax(body,abs(ax)-0.11,0.04);
    float grip=max(length(rr)-0.075, abs(ax+0.16)-0.06);
    float plug=smin(body,grip,0.04);
    res=opU(res,vec2(plug,3.));
    vec3 side=normalize(cross(PD,vec3(0.,1.,0.)));
    vec3 c0=PL+vec3(0.,0.105,0.)+PD*0.12;
    float pins=min(sdCap(p,c0+side*0.035,c0+side*0.035+PD*0.13,0.011), sdCap(p,c0-side*0.035,c0-side*0.035+PD*0.13,0.011));
    res=opU(res,vec2(pins,2.));
    vec3 k0=PL+vec3(0.,0.105,0.)-PD*0.22;
    vec3 k1=k0-PD*0.15+vec3(0.,-0.05,0.);
    vec3 k2=k1-PD*0.12+side*0.14+vec3(0.,-0.05,0.);
    vec3 k3=k2+side*0.25+PD*0.05;
    vec3 k4=k3+side*0.2+PD*0.2;
    float cab=min(min(sdCap(p,k0,k1,0.028),sdCap(p,k1,k2,0.028)),min(sdCap(p,k2,k3,0.028),sdCap(p,k3,k4,0.028)));
    res=opU(res,vec2(cab,4.));
  } else res=opU(res,vec2(bl,3.));
  return res;
}
Mat getMat(float id, vec3 p, vec3 n){
  if(id<1.5) return M(vec3(0.91,0.905,0.89),0.22,0.,0.6);
  if(id<2.5) return M(vec3(0.96,0.96,0.97),0.06,1.,0.5);
  if(id<3.5) return M(vec3(0.92,0.91,0.89),0.35,0.,0.5);
  return M(vec3(0.07,0.075,0.08),0.45,0.,0.5);
}
