function [Y,T] = odefun
pset=load('params.mat');
tspan=pset.p.timelimits; dt=pset.p.dt;
T=tspan(1):dt:tspan(2); nstep=length(T);
fprintf('\nSimulation interval: %g-%g\n',tspan(1),tspan(2));
fprintf('Starting integration (euler, dt=%g)\n',dt);
E_input_offset = [Inf];
I_E_GABAa_fanout = [Inf];
I_E_GABAa_Nmax = max(pset.p.I_Npop,pset.p.E_Npop);
I_E_GABAa_srcpos = linspace(1,I_E_GABAa_Nmax,pset.p.I_Npop)'*ones(1,pset.p.E_Npop);
I_E_GABAa_dstpos = (linspace(1,I_E_GABAa_Nmax,pset.p.E_Npop)'*ones(1,pset.p.I_Npop))';
I_E_GABAa_mask = abs(I_E_GABAa_srcpos-I_E_GABAa_dstpos)<=I_E_GABAa_fanout;
I_input_offset = [Inf];
E_I_AMPA_fanout = [Inf];
E_I_AMPA_Nmax = max(pset.p.E_Npop,pset.p.I_Npop);
E_I_AMPA_srcpos = linspace(1,E_I_AMPA_Nmax,pset.p.E_Npop)'*ones(1,pset.p.I_Npop);
E_I_AMPA_dstpos = (linspace(1,E_I_AMPA_Nmax,pset.p.I_Npop)'*ones(1,pset.p.E_Npop))';
E_I_AMPA_mask = abs(E_I_AMPA_srcpos-E_I_AMPA_dstpos)<=E_I_AMPA_fanout;
E_V = zeros(1,nstep);
E_V(1) = pset.p.IC_E_V;
E_K_nKf = zeros(1,nstep);
E_K_nKf(1) = pset.p.IC_E_K_nKf;
E_Na_mNaf = zeros(1,nstep);
E_Na_mNaf(1) = pset.p.IC_E_Na_mNaf;
E_Na_hNaf = zeros(1,nstep);
E_Na_hNaf(1) = pset.p.IC_E_Na_hNaf;
I_E_GABAa_s = zeros(1,nstep);
I_E_GABAa_s(1) = pset.p.IC_I_E_GABAa_s;
I_V = zeros(1,nstep);
I_V(1) = pset.p.IC_I_V;
I_K_nKf = zeros(1,nstep);
I_K_nKf(1) = pset.p.IC_I_K_nKf;
I_Na_mNaf = zeros(1,nstep);
I_Na_mNaf(1) = pset.p.IC_I_Na_mNaf;
I_Na_hNaf = zeros(1,nstep);
I_Na_hNaf(1) = pset.p.IC_I_Na_hNaf;
E_I_AMPA_s = zeros(1,nstep);
E_I_AMPA_s(1) = pset.p.IC_E_I_AMPA_s;
for k=2:nstep
  t=T(k-1);
  F=(((-(pset.p.E_K_gKf.*E_K_nKf(k-1).^4.*(E_V(k-1)-pset.p.E_K_EKf)))+((-(pset.p.E_Na_gNa.*E_Na_mNaf(k-1).^3.*E_Na_hNaf(k-1).*(E_V(k-1)-pset.p.E_Na_ENa)))+((-(pset.p.E_leak_g_l.*(E_V(k-1)-pset.p.E_leak_E_l)))+(((pset.p.E_input_stim*(t>pset.p.E_input_onset & t<E_input_offset)))+(((pset.p.E_randn_noise.*randn(pset.p.E_Npop,1).*sqrt(dt)))+((-((pset.p.I_E_GABAa_g_SYN.*(I_E_GABAa_s(k-1)'*I_E_GABAa_mask)'.*(E_V(k-1)-pset.p.I_E_GABAa_E_SYN))))+0)))))))./pset.p.E_K_Cm;
  E_V(k) = E_V(k-1) + dt*F;
  F=((.1-.01*(E_V(k-1)+65))./(exp(1-.1*(E_V(k-1)+65))-1)).*(1-E_K_nKf(k-1))-(.125*exp(-(E_V(k-1)+65)/80)).*E_K_nKf(k-1);
  E_K_nKf(k) = E_K_nKf(k-1) + dt*F;
  F=((2.5-.1*(E_V(k-1)+65))./(exp(2.5-.1*(E_V(k-1)+65))-1)).*(1-E_Na_mNaf(k-1))-(4*exp(-(E_V(k-1)+65)/18)).*E_Na_mNaf(k-1);
  E_Na_mNaf(k) = E_Na_mNaf(k-1) + dt*F;
  F=(.07*exp(-(E_V(k-1)+65)/20)).*(1-E_Na_hNaf(k-1))-(1./(exp(3-.1*(E_V(k-1)+65))+1)).*E_Na_hNaf(k-1);
  E_Na_hNaf(k) = E_Na_hNaf(k-1) + dt*F;
  F=-I_E_GABAa_s(k-1)./pset.p.I_E_GABAa_tauDx + ((1-I_E_GABAa_s(k-1))/pset.p.I_E_GABAa_tauRx).*(1+tanh(I_V(k-1)/10));
  I_E_GABAa_s(k) = I_E_GABAa_s(k-1) + dt*F;
  F=(((-(pset.p.I_K_gKf.*I_K_nKf(k-1).^4.*(I_V(k-1)-pset.p.I_K_EKf)))+((-(pset.p.I_Na_gNa.*I_Na_mNaf(k-1).^3.*I_Na_hNaf(k-1).*(I_V(k-1)-pset.p.I_Na_ENa)))+((-(pset.p.I_leak_g_l.*(I_V(k-1)-pset.p.I_leak_E_l)))+(((pset.p.I_input_stim*(t>pset.p.I_input_onset & t<I_input_offset)))+(((pset.p.I_randn_noise.*randn(pset.p.I_Npop,1).*sqrt(dt)))+((-((pset.p.E_I_AMPA_g_SYN.*(E_I_AMPA_s(k-1)'*E_I_AMPA_mask)'.*(I_V(k-1)-pset.p.E_I_AMPA_E_SYN))))+0)))))))./pset.p.E_K_Cm;
  I_V(k) = I_V(k-1) + dt*F;
  F=((.1-.01*(I_V(k-1)+65))./(exp(1-.1*(I_V(k-1)+65))-1)).*(1-I_K_nKf(k-1))-(.125*exp(-(I_V(k-1)+65)/80)).*I_K_nKf(k-1);
  I_K_nKf(k) = I_K_nKf(k-1) + dt*F;
  F=((2.5-.1*(I_V(k-1)+65))./(exp(2.5-.1*(I_V(k-1)+65))-1)).*(1-I_Na_mNaf(k-1))-(4*exp(-(I_V(k-1)+65)/18)).*I_Na_mNaf(k-1);
  I_Na_mNaf(k) = I_Na_mNaf(k-1) + dt*F;
  F=(.07*exp(-(I_V(k-1)+65)/20)).*(1-I_Na_hNaf(k-1))-(1./(exp(3-.1*(I_V(k-1)+65))+1)).*I_Na_hNaf(k-1);
  I_Na_hNaf(k) = I_Na_hNaf(k-1) + dt*F;
  F=-E_I_AMPA_s(k-1)./pset.p.E_I_AMPA_tauDx + ((1-E_I_AMPA_s(k-1))/pset.p.E_I_AMPA_tauRx).*(1+tanh(E_V(k-1)/10));;
  E_I_AMPA_s(k) = E_I_AMPA_s(k-1) + dt*F;
end
Y=cat(1,E_V,E_K_nKf,E_Na_mNaf,E_Na_hNaf,I_E_GABAa_s,I_V,I_K_nKf,I_Na_mNaf,I_Na_hNaf,E_I_AMPA_s)';
