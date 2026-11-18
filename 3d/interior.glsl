#define SRGB_ALB
#define OPAQUE_BG
#define SUN_DIR vec3(-0.8,0.45,0.1)
#define SUN_COL (vec3(1.0,0.92,0.80)*4.2)
#define SKY_COL (vec3(0.80,0.82,0.86)*0.95)
#define BOUNCE_COL (vec3(0.95,0.85,0.70)*0.35)
#define BACK_COL (vec3(0.95,0.95,1.0)*0.15)
#define HORIZON_COL vec3(0.95,0.95,0.94)
#define ZENITH_COL vec3(0.80,0.86,0.93)
#define GROUND_ENV vec3(0.6,0.58,0.55)
#define ENV_STRENGTH 0.8
#define EXPOSURE 1.0
#define SHADOW_K 10.
#define GROUND_Y -50.
#define SHADOW_TINT vec3(0.)
#define SHADOW_CENTER vec2(0.)
#define TMAX 30.
const vec3 CAM_POS=vec3(1.9,1.25,1.6);
const vec3 CAM_TGT=vec3(-0.5,0.95,-2.5);
const float FOCAL=1.45;

vec2 map(vec3 p){
  vec2 res=vec2(sdBox(p-vec3(0.,-0.1,-1.),vec3(4.5,0.1,4.6)),1.);  // пол
  res=opU(res,vec2(sdBox(p-vec3(0.,3.1,-1.),vec3(4.5,0.1,4.6)),2.));  // потолок
  res=opU(res,vec2(p.z+3.0,2.));                          // задняя стена
  res=opU(res,vec2(4.4-p.x,2.));                          // правая стена
  float lw=abs(p.x+4.3)-0.1;                                       // левая стена с окном
  float win=sdBox(p-vec3(-4.2,1.65,-0.6),vec3(0.4,1.05,1.35));
  lw=max(lw,-win);
  res=opU(res,vec2(lw,2.));
  res=opU(res,vec2(max(sdBox(p-vec3(-4.2,1.65,-0.6),vec3(0.05,1.05,0.03)),-0.),5.));
  // ковёр
  res=opU(res,vec2(sdRBox(p-vec3(0.2,0.008,-1.4),vec3(1.6,0.008,1.15),0.005),3.));
  // диван
  vec3 s=p-vec3(0.2,0.,-2.45);
  float sofa=sdRBox(s-vec3(0.,0.26,0.),vec3(1.45,0.18,0.48),0.07);
  sofa=min(sofa,sdRBox(s-vec3(-0.68,0.53,0.06),vec3(0.66,0.1,0.4),0.09));
  sofa=min(sofa,sdRBox(s-vec3(0.68,0.53,0.06),vec3(0.66,0.1,0.4),0.09));
  sofa=min(sofa,sdRBox(s-vec3(-0.68,0.86,-0.36),vec3(0.65,0.26,0.12),0.11));
  sofa=min(sofa,sdRBox(s-vec3(0.68,0.86,-0.36),vec3(0.65,0.26,0.12),0.11));
  sofa=min(sofa,sdRBox(s-vec3(-1.42,0.5,0.),vec3(0.13,0.3,0.48),0.1));
  sofa=min(sofa,sdRBox(s-vec3(1.42,0.5,0.),vec3(0.13,0.3,0.48),0.1));
  res=opU(res,vec2(sofa,4.));
  vec3 c1=s-vec3(-1.0,0.82,-0.18); c1.xy*=rot(0.2);
  res=opU(res,vec2(sdRBox(c1,vec3(0.22,0.2,0.07),0.08),6.));
  vec3 c2=s-vec3(0.95,0.8,-0.18); c2.xy*=rot(-0.15);
  res=opU(res,vec2(sdRBox(c2,vec3(0.2,0.18,0.07),0.08),7.));
  // журнальный столик
  res=opU(res,vec2(sdRCylY(p-vec3(0.35,0.42,-1.25),0.55,0.03,0.015),8.));
  res=opU(res,vec2(sdCylY(p-vec3(0.35,0.2,-1.25),0.06,0.2),8.));
  res=opU(res,vec2(sdRCylY(p-vec3(0.35,0.02,-1.25),0.3,0.02,0.01),8.));
  res=opU(res,vec2(sdRCylY(p-vec3(0.15,0.5,-1.2),0.07,0.05,0.01),11.));
  // торшер
  vec3 l=p-vec3(2.05,0.,-2.6);
  res=opU(res,vec2(sdRCylY(l-vec3(0.,0.015,0.),0.2,0.015,0.008),9.));
  res=opU(res,vec2(sdCap(l,vec3(0.),vec3(0.,1.55,0.),0.015),9.));
  res=opU(res,vec2(sdRCylY(l-vec3(0.,1.62,0.),0.24,0.17,0.02),10.));
  // растение
  vec3 q=p-vec3(-1.75,0.,-2.5);
  res=opU(res,vec2(sdRCylY(q-vec3(0.,0.25,0.),0.22,0.25,0.03),11.));
  float lv=sdEll(q-vec3(0.,1.05,0.),vec3(0.5,0.65,0.5));
  if(lv<0.5) lv+=0.25*(noise3(q*4.)-0.5)+0.12*(noise3(q*9.)-0.5);
  lv=smin(lv,sdEll(q-vec3(0.25,0.75,0.15),vec3(0.35,0.3,0.3))+0.15*(noise3(q*5.)-0.5),0.2);
  res=opU(res,vec2(lv*0.8,12.));
  // картины
  res=opU(res,vec2(sdBox(p-vec3(-0.35,1.85,-2.98),vec3(0.42,0.32,0.02)),13.));
  res=opU(res,vec2(sdBox(p-vec3(0.75,1.75,-2.98),vec3(0.3,0.42,0.02)),14.));
  // полка у правой стены
  res=opU(res,vec2(sdRBox(p-vec3(4.1,0.45,-1.4),vec3(0.3,0.45,0.9),0.02),15.));
  return res;
}
Mat getMat(float id, vec3 p, vec3 n){
  if(id<1.5){ float pl=floor(p.x/0.2); float g=noise3(vec3(pl*7.,0.,p.z*0.6+pl))*0.5+noise3(vec3(p.x*30.,0.,p.z*3.))*0.5; float gap=smoothstep(0.,0.03,fract(p.x/0.2))*smoothstep(1.,0.97,fract(p.x/0.2)); return M(mix(vec3(0.72,0.56,0.40),vec3(0.82,0.66,0.48),g)*(0.75+0.25*gap),0.45,0.,0.5); }
  if(id<2.5) return M(vec3(0.94,0.93,0.90),0.9,0.,0.3);
  if(id<3.5) return M(vec3(0.88,0.86,0.82)*(0.94+0.08*noise3(p*40.)),0.95,0.,0.2);
  if(id<4.5) return M(vec3(0.80,0.78,0.74)*(0.95+0.06*noise3(p*60.)),0.9,0.,0.25);
  if(id<5.5) return M(vec3(0.9),0.5,0.,0.4);
  if(id<6.5) return M(vec3(0.52,0.66,0.56),0.9,0.,0.2);
  if(id<7.5) return M(vec3(0.86,0.62,0.48),0.9,0.,0.2);
  if(id<8.5) return M(vec3(0.42,0.28,0.18),0.35,0.,0.5);
  if(id<9.5) return M(vec3(0.08),0.3,0.6,0.5);
  if(id<10.5){ Mat m=M(vec3(0.96,0.94,0.9),0.8,0.,0.3); m.emi=vec3(1.,0.8,0.55)*0.6; return m; }
  if(id<11.5) return M(vec3(0.93,0.92,0.89),0.4,0.,0.5);
  if(id<12.5){ float g=noise3(p*6.); return M(mix(vec3(0.16,0.32,0.14),vec3(0.30,0.48,0.22),g),0.6,0.,0.4); }
  if(id<13.5) return M(mix(vec3(0.55,0.68,0.58),vec3(0.90,0.84,0.74),step(0.,p.x+0.35+0.2*sin(p.y*6.))),0.7,0.,0.3);
  if(id<14.5) return M(mix(vec3(0.92,0.86,0.76),vec3(0.80,0.55,0.40),step(1.75,p.y+0.15*sin(p.x*9.))),0.7,0.,0.3);
  return M(vec3(0.62,0.48,0.34),0.5,0.,0.4);
}
