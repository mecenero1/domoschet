#version 300 es
precision highp float;
uniform vec2 uRes;
uniform int uSpp;
out vec4 outColor;

#define PI 3.14159265
struct Mat { vec3 alb; float rough; float metal; float spec; vec3 emi; };
Mat M(vec3 a,float r,float mt,float sp){ Mat m; m.alb=a; m.rough=r; m.metal=mt; m.spec=sp; m.emi=vec3(0.); return m; }

float sdBox(vec3 p, vec3 b){ vec3 q=abs(p)-b; return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.); }
float sdRBox(vec3 p, vec3 b, float r){ vec3 q=abs(p)-b+r; return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.)-r; }
float sdSph(vec3 p, float r){ return length(p)-r; }
float sdCylY(vec3 p, float r, float h){ vec2 d=abs(vec2(length(p.xz),p.y))-vec2(r,h); return min(max(d.x,d.y),0.)+length(max(d,0.)); }
float sdRCylY(vec3 p, float r, float h, float rr){ vec2 d=vec2(length(p.xz)-r+rr, abs(p.y)-h+rr); return min(max(d.x,d.y),0.)+length(max(d,0.))-rr; }
float sdCap(vec3 p, vec3 a, vec3 b, float r){ vec3 pa=p-a, ba=b-a; float h=clamp(dot(pa,ba)/dot(ba,ba),0.,1.); return length(pa-ba*h)-r; }
float sdTorus(vec3 p, vec2 t){ vec2 q=vec2(length(p.xz)-t.x,p.y); return length(q)-t.y; }
float sdEll(vec3 p, vec3 r){ float k0=length(p/r); float k1=length(p/(r*r)); return k0*(k0-1.)/k1; }
mat2 rot(float a){ float c=cos(a), s=sin(a); return mat2(c,-s,s,c); }
float smin(float a, float b, float k){ float h=max(k-abs(a-b),0.)/k; return min(a,b)-h*h*k*.25; }
float smax(float a, float b, float k){ return -smin(-a,-b,k); }
vec2 opU(vec2 a, vec2 b){ return a.x<b.x?a:b; }

float hash13(vec3 p){ p=fract(p*0.1031); p+=dot(p,p.zyx+31.32); return fract((p.x+p.y)*p.z); }
float hash12(vec2 p){ vec3 p3=fract(vec3(p.xyx)*.1031); p3+=dot(p3,p3.yzx+33.33); return fract((p3.x+p3.y)*p3.z); }
float noise3(vec3 x){ vec3 i=floor(x), f=fract(x); f=f*f*(3.-2.*f);
  return mix(mix(mix(hash13(i),hash13(i+vec3(1,0,0)),f.x),mix(hash13(i+vec3(0,1,0)),hash13(i+vec3(1,1,0)),f.x),f.y),
             mix(mix(hash13(i+vec3(0,0,1)),hash13(i+vec3(1,0,1)),f.x),mix(hash13(i+vec3(0,1,1)),hash13(i+vec3(1,1,1)),f.x),f.y),f.z); }
float fbm(vec3 p){ float a=.5, s=0.; for(int i=0;i<4;i++){ s+=a*noise3(p); p*=2.03; a*=.5; } return s; }
