
#include studio
const vec3 CAM_POS=vec3(2.3,2.15,3.0);
const vec3 CAM_TGT=vec3(0.,0.17,0.);
#if VARIANT==3||VARIANT==4||VARIANT==5
const float FOCAL=5.4;
#else
const float FOCAL=4.6;
#endif

vec2 map(vec3 p){
  vec2 res=vec2(1e9,0.);
#if VARIANT==1
  // рулон обоев
  vec3 r=p-vec3(-0.05,0.27,-0.15);
  float roll=sdRCylY(r.yxz,0.26,0.5,0.01);
  float core=sdCylY(r.yxz,0.05,0.6);
  roll=max(roll,-core);
  res=opU(res,vec2(roll,1.));
  res=opU(res,vec2(sdRBox(p-vec3(-0.05,0.005,0.28),vec3(0.5,0.005,0.42),0.003),2.));
  res=opU(res,vec2(max(sdCylY(r.yxz,0.06,0.5),-core),3.));
#elif VARIANT==2
  // банка краски
  vec3 c=p-vec3(0.,0.,0.);
  float can=sdRCylY(c-vec3(0.,0.33,0.),0.36,0.33,0.01);
  can=min(can,sdTorus(c-vec3(0.,0.655,0.),vec2(0.35,0.018)));
  can=min(can,sdTorus(c-vec3(0.,0.03,0.),vec2(0.355,0.012)));
  res=opU(res,vec2(can,14.));
  res=opU(res,vec2(sdRCylY(c-vec3(0.,0.665,0.),0.33,0.012,0.006),4.));
  vec3 h=c-vec3(0.,0.6,0.); h.yz*=rot(-0.35);
  float hd=sdTorus(h.xzy,vec2(0.37,0.01)); hd=max(hd,-h.y);
  res=opU(res,vec2(hd,4.));
#elif VARIANT==3
  // плитка стопкой
  vec3 a=p-vec3(0.,0.022,0.); a.xz*=rot(0.32); res=opU(res,vec2(sdRBox(a,vec3(0.36,0.02,0.36),0.008),5.));
  vec3 b=p-vec3(0.04,0.066,-0.02); b.xz*=rot(-0.12); res=opU(res,vec2(sdRBox(b,vec3(0.36,0.02,0.36),0.008),5.));
  vec3 c=p-vec3(-0.02,0.11,0.03); c.xz*=rot(0.12); res=opU(res,vec2(sdRBox(c,vec3(0.36,0.02,0.36),0.008),6.));
#elif VARIANT==4
  // доски ламината
  vec3 a=p-vec3(0.,0.025,-0.11); a.xz*=rot(0.04); res=opU(res,vec2(sdRBox(a,vec3(0.6,0.022,0.1),0.006),7.));
  vec3 b=p-vec3(0.03,0.025,0.1); b.xz*=rot(0.02); res=opU(res,vec2(sdRBox(b,vec3(0.6,0.022,0.1),0.006),7.));
  vec3 c=p-vec3(-0.12,0.072,0.); c.xz*=rot(1.5); res=opU(res,vec2(sdRBox(c,vec3(0.6,0.022,0.1),0.006),7.));
  vec3 d=p-vec3(0.12,0.072,0.02); d.xz*=rot(1.62); res=opU(res,vec2(sdRBox(d,vec3(0.6,0.022,0.1),0.006),7.));
  vec3 e=p-vec3(0.,0.119,0.); e.xz*=rot(0.75); res=opU(res,vec2(sdRBox(e,vec3(0.6,0.022,0.1),0.006),7.));
#elif VARIANT==5
  // гладилка и раствор
  vec3 t=p-vec3(-0.08,0.,0.05); t.xz*=rot(0.4);
  res=opU(res,vec2(sdRBox(t-vec3(0.,0.008,0.),vec3(0.42,0.007,0.17),0.006),8.));
  float br=min(sdCap(t,vec3(-0.22,0.01,0.),vec3(-0.19,0.14,0.),0.012), sdCap(t,vec3(0.22,0.01,0.),vec3(0.19,0.14,0.),0.012));
  br=min(br,sdCap(t,vec3(-0.19,0.14,0.),vec3(-0.15,0.15,0.),0.012));
  br=min(br,sdCap(t,vec3(0.19,0.14,0.),vec3(0.15,0.15,0.),0.012));
  res=opU(res,vec2(br,8.));
  res=opU(res,vec2(sdCap(t,vec3(-0.16,0.16,0.),vec3(0.16,0.16,0.),0.045),9.));
  vec3 g=p-vec3(0.36,0.,-0.36);
  float pile=sdEll(g,vec3(0.24,0.13,0.22));
  if(pile<0.2) pile+=0.04*(noise3(g*14.)-0.5);
  res=opU(res,vec2(pile*0.8,10.));
#elif VARIANT==6
  // газоблок и кирпич
  vec3 a=p-vec3(0.,0.2,0.); a.xz*=rot(0.1);
  res=opU(res,vec2(sdRBox(a,vec3(0.5,0.2,0.24),0.012),11.));
  vec3 b=p-vec3(0.08,0.478,0.02); b.xz*=rot(-0.4);
  res=opU(res,vec2(sdRBox(b,vec3(0.3,0.078,0.145),0.015),12.));
#else
  // мешок
  vec3 s=p-vec3(0.,0.16,0.); s.xz*=rot(0.15);
  float bag=sdRBox(s,vec3(0.48,0.08,0.3),0.08);
  bag=smin(bag,sdEll(s-vec3(0.,0.03,0.),vec3(0.46,0.15,0.3)),0.1);
  res=opU(res,vec2(bag,13.));
#endif
  return res;
}
Mat getMat(float id, vec3 p, vec3 n){
  if(id<1.5){
    vec3 r=p-vec3(-0.05,0.27,-0.15);
    if(abs(r.x)>0.49){ float rr=length(r.yz); float ring=smoothstep(0.3,0.5,abs(fract(rr*55.)-0.5)*2.); return M(mix(vec3(0.62,0.70,0.63),vec3(0.88,0.88,0.84),ring),0.8,0.,0.3); }
    float st=smoothstep(0.42,0.5,abs(fract(r.x*7.)-0.5)*2.);
    return M(mix(vec3(0.80,0.84,0.78),vec3(0.38,0.54,0.44),st),0.75,0.,0.3);
  }
  if(id<2.5){ float st=smoothstep(0.42,0.5,abs(fract((p.x+0.05)*7.)-0.5)*2.); return M(mix(vec3(0.80,0.84,0.78),vec3(0.38,0.54,0.44),st),0.75,0.,0.3); }
  if(id<3.5) return M(vec3(0.62,0.50,0.36),0.9,0.,0.2);
  if(id<4.5) return M(vec3(0.78,0.79,0.80),0.28,1.,0.5);
  if(id<1.5+0.) return M(vec3(1.),1.,0.,0.);
  if(id<5.5){ float g=noise3(p*12.)*0.6+noise3(p*40.)*0.4; return M(mix(vec3(0.80,0.78,0.74),vec3(0.90,0.89,0.86),g),0.2,0.,0.7); }
  if(id<6.5){ float g=noise3(p*18.); return M(mix(vec3(0.24,0.40,0.32),vec3(0.32,0.50,0.40),g),0.1,0.,0.9); }
  if(id<7.5){ float g=noise3(vec3(p.x*3.,p.y*40.,p.z*40.))*0.6+noise3(p*vec3(1.,30.,30.))*0.4; return M(mix(vec3(0.44,0.29,0.16),vec3(0.62,0.44,0.27),g),0.45,0.,0.5); }
  if(id<8.5) return M(vec3(0.82,0.83,0.85),0.22,1.,0.5);
  if(id<9.5){ float g=noise3(vec3(p.x*30.,p.y*4.,p.z*4.)); return M(vec3(0.50,0.33,0.20)*(0.85+0.3*g),0.5,0.,0.5); }
  if(id<10.5) return M(vec3(0.70,0.69,0.66)*(0.9+0.15*noise3(p*30.)),0.9,0.,0.2);
  if(id<11.5){ float pore=step(0.86,hash13(floor(p*160.))); return M(vec3(0.88,0.87,0.84)*(1.-0.35*pore)*(0.94+0.08*noise3(p*20.)),0.95,0.,0.2); }
  if(id<12.5){ float g=noise3(p*25.); return M(mix(vec3(0.42,0.15,0.08),vec3(0.52,0.21,0.11),g),0.85,0.,0.3); }
  if(id<13.5){ vec3 s=p-vec3(0.,0.16,0.); s.xz*=rot(0.15);
  vec3 kraft=vec3(0.62,0.48,0.32)*(0.92+0.1*noise3(p*35.));
  if(abs(s.x)<0.18) kraft=vec3(0.18,0.38,0.28);
  if(abs(s.x)<0.18&&abs(s.z)<0.06&&s.y>0.0) kraft=vec3(0.92,0.9,0.85);
  return M(kraft,0.85,0.,0.3); }
  // банка: металл и этикетка
  Mat m=M(vec3(0.80,0.81,0.82),0.3,1.,0.5);
  if(p.y>0.12&&p.y<0.55&&length(p.xz)>0.355){ m=M(vec3(0.16,0.36,0.27),0.45,0.,0.5); if(p.y>0.27&&p.y<0.39) m=M(vec3(0.93,0.91,0.86),0.5,0.,0.4); }
  return m;
}
