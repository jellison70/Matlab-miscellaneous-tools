%function plotVfit_speechmap

clear 
close all
current = cd;
[fname, fpath] = uigetfile('*.xml', 'Choose a .XML file');
cd(current);
rawfile = xml2struct(fname);

freqs = cell2mat(textscan(char(rawfile.session.test{1,1}.data{1,3}.Text),'%f'));
audiofreqs = [250.0 500.0 750.0 1000.0 1500.0 2000.0 3000.0 4000.0 6000.0 8000.0 10000.0 12500.0];
len = length(rawfile.session.test{1,17}.data);
for i = 1:len
    idx_mpo{:,i} = structfun(@(x) any(strcmp(x, 'mpo')),rawfile.session.test{1,17}.data{1,i}.Attributes);
    sum_mpo(:,i) = sum(idx_mpo{1,i});
    idx_noise{:,i} = structfun(@(x) any(strcmp(x, 'noise')),rawfile.session.test{1,17}.data{1,i}.Attributes);
    sum_noise(:,i) = sum(idx_noise{1,i});
    idx_s{:,i} = structfun(@(x) any(strcmp(x, 'speech-s')),rawfile.session.test{1,17}.data{1,i}.Attributes);
    sum_s(:,i) = sum(idx_s{1,i});
    idx_sh{:,i} = structfun(@(x) any(strcmp(x, 'speech-sh')),rawfile.session.test{1,17}.data{1,i}.Attributes);
    sum_sh(:,i) = sum(idx_sh{1,i});
    idx_peaks{:,i} = structfun(@(x) any(strcmp(x, 'peaks')),rawfile.session.test{1,17}.data{1,i}.Attributes);
    sum_peaks(:,i) = sum(idx_peaks{1,i});
    idx_th{:,i} = structfun(@(x) any(strcmp(x, 'threshold')),rawfile.session.test{1,17}.data{1,i}.Attributes);
    sum_th(:,i) = sum(idx_th{1,i});
end
clear i;
idx_mpo = find(sum_mpo==1);
idx_noise = find(sum_noise==1);
idx_s = find(sum_s==1);
idx_sh = find(sum_sh==1);
idx_peaks = find(sum_peaks==1); 
idx_peaks = idx_peaks(1:length(idx_peaks)/2);
idx_th= find(sum_th==1);
%gather MPO data ----------------------------------
if ~isempty(idx_mpo)
    for i = 1:length(idx_mpo)
        mpo_avg(:,i) = cell2mat(textscan(char(rawfile.session.test{1,17}.data{1,idx_mpo(i)}.Text),'%f'));
        mpo_name{:,i} = rawfile.session.test{1,17}.data{1,idx_mpo(i)}.Attributes.name;
        mpo_stim_level{:,i} = rawfile.session.test{1,17}.data{1,idx_mpo(i)}.Attributes.mpo_level;
        mpo_stim_type{:,i} = rawfile.session.test{1,17}.data{1,idx_mpo(i)}.Attributes.stim_type;
    end
    clear i;
end
%gather Noise data---------------------------------
if ~isempty(idx_noise)
    for i = 1:length(idx_noise)
        noise_avg(:,i) = cell2mat(textscan(char(rawfile.session.test{1,17}.data{1,idx_noise(i)}.Text),'%f'));
        noise_name{:,i} = rawfile.session.test{1,17}.data{1,idx_noise(i)}.Attributes.name;
        noise_stim_level{:,i} = rawfile.session.test{1,17}.data{1,idx_noise(i)}.Attributes.noise_level;
        noise_stim_type{:,i} = rawfile.session.test{1,17}.data{1,idx_noise(i)}.Attributes.stim_type;
    end
    clear i;
end
%gather speech-s -----------------------
if ~isempty(idx_s)
    for i = 1:length(idx_s)
        s_avg(:,i) = cell2mat(textscan(char(rawfile.session.test{1,17}.data{1,idx_s(i)}.Text),'%f'));
        s_name{:,i} = rawfile.session.test{1,17}.data{1,idx_s(i)}.Attributes.name;
        s_stim_level{:,i} = rawfile.session.test{1,17}.data{1,idx_s(i)}.Attributes.stim_level;
        s_stim_type{:,i} = rawfile.session.test{1,17}.data{1,idx_s(i)}.Attributes.stim_type;
    end
    clear i;
end
%gather speech-sh ------------------------------
if ~isempty(idx_sh)
    for i = 1:length(idx_sh)
        sh_avg(:,i) = cell2mat(textscan(char(rawfile.session.test{1,17}.data{1,idx_sh(i)}.Text),'%f'));
        sh_name{:,i} = rawfile.session.test{1,17}.data{1,idx_sh(i)}.Attributes.name;
        sh_stim_level{:,i} = rawfile.session.test{1,17}.data{1,idx_sh(i)}.Attributes.stim_level;
        sh_stim_type{:,i} = rawfile.session.test{1,17}.data{1,idx_sh(i)}.Attributes.stim_type;
    end
    clear i;
end
%gather signals with peaks and valley
if ~isempty(idx_peaks)
    for i = 1:length(idx_peaks)
        mod_peaks(:,i) = cell2mat(textscan(char(rawfile.session.test{1,17}.data{1,idx_peaks(i)}.Text),'%f'));
        mod_avg(:,i) = cell2mat(textscan(char(rawfile.session.test{1,17}.data{1,idx_peaks(i)+1}.Text),'%f'));
        mod_valleys(:,i) = cell2mat(textscan(char(rawfile.session.test{1,17}.data{1,idx_peaks(i)+2}.Text),'%f'));
        mod_name{:,i} = rawfile.session.test{1,17}.data{1,idx_peaks(i)+1}.Attributes.name;
        mod_stim_level{:,i} = rawfile.session.test{1,17}.data{1,idx_peaks(i)+1}.Attributes.stim_level;
        mod_stim_type{:,i} = rawfile.session.test{1,17}.data{1,idx_peaks(i)+1}.Attributes.stim_type;
    end
    clear i;
end
%gather thresholds (SPL)
if ~isempty(idx_th)
    th_name = rawfile.session.test{1,17}.data{1,idx_th(1)}.Attributes.name;
    audioThresh = rawfile.session.test{1,17}.data{1,end-1}.Text;
    audioThresh = strsplit(audioThresh);
    for i = 1:12
        a(i) = textscan(audioThresh{i},'%f');
    end
    clear i;
    empties = cellfun('isempty',a);
    a(empties) = {NaN};
    a=cell2mat(a);
    I = ~isnan(a);
    audioThresh = a;
    clear a;
end

if exist('mpo_name','var')
    if find(contains(mpo_name, 'test1')) ~= 0 
        test1 = mpo_avg(:,contains(mpo_name, 'test1'));
        test1_stim = mpo_stim_type(:,contains(mpo_name, 'test1'));
        test1_level = mpo_stim_level(:,contains(mpo_name, 'test1'));
        test1_name = mpo_name(:,contains(mpo_name, 'test1'));
    end
    if find(contains(mpo_name, 'test2')) ~= 0 
        test2 = mpo_avg(:,contains(mpo_name, 'test2'));
        test2_stim = mpo_stim_type(:,contains(mpo_name, 'test2'));
        test2_level = mpo_stim_level(:,contains(mpo_name, 'test2'));
        test2_name = mpo_name(:,contains(mpo_name, 'test2'));
    end
    if find(contains(mpo_name, 'test3')) ~= 0 
        test3 = mpo_avg(:,contains(mpo_name, 'test3'));
        test3_stim = mpo_stim_type(:,contains(mpo_name, 'test3'));
        test3_level = mpo_stim_level(:,contains(mpo_name, 'test3'));
        test3_name = mpo_name(:,contains(mpo_name, 'test3'));
    end
    if find(contains(mpo_name, 'test4')) ~= 0 
        test4 = mpo_avg(:,contains(mpo_name, 'test4'));
        test4_stim = mpo_stim_type(:,contains(mpo_name, 'test4'));
        test4_level = mpo_stim_level(:,contains(mpo_name, 'test4'));
        test4_name = mpo_name(:,contains(mpo_name, 'test4'));
    end
end
if exist('noise_name','var')
    if find(contains(noise_name, 'test1')) ~= 0 
        test1 = noise_avg(:,contains(noise_name, 'test1'));
        test1_stim = noise_stim_type(:,contains(noise_name, 'test1'));
        test1_level = noise_stim_level(:,contains(noise_name, 'test1'));
        test1_name = noise_name(:,contains(noise_name, 'test1'));
    end
    if find(contains(noise_name, 'test2')) ~= 0 
        test2 = noise_avg(:,contains(noise_name, 'test2'));
        test2_stim = noise_stim_type(:,contains(noise_name, 'test2'));
        test2_level = noise_stim_level(:,contains(noise_name, 'test2'));
        test2_name = noise_name(:,contains(noise_name, 'test2'));
    end
    if find(contains(noise_name, 'test3')) ~= 0 
        test3 = noise_avg(:,contains(noise_name, 'test3'));
        test3_stim = noise_stim_type(:,contains(noise_name, 'test3'));
        test3_level = noise_stim_level(:,contains(noise_name, 'test3'));
        test3_name = noise_name(:,contains(noise_name, 'test3'));
    end
    if find(contains(noise_name, 'test4')) ~= 0 
        test4 = noise_avg(:,contains(noise_name, 'test4'));
        test4_stim = noise_stim_type(:,contains(noise_name, 'test4'));
        test4_level = noise_stim_level(:,contains(noise_name, 'test4'));
        test4_name = noise_name(:,contains(noise_name, 'test4'));
    end
end
if exist('s_name','var')
    if find(contains(s_name, 'test1')) ~= 0 
        test1 = s_avg(:,contains(s_name, 'test1'));
        test1_stim = s_stim_type(:,contains(s_name, 'test1'));
        test1_level = s_stim_level(:,contains(s_name, 'test1'));
        test1_name = s_name(:,contains(s_name, 'test1'));
    end
    if find(contains(s_name, 'test2')) ~= 0 
        test2 = s_avg(:,contains(s_name, 'test2'));
        test2_stim = s_stim_type(:,contains(s_name, 'test2'));
        test2_level = s_stim_level(:,contains(s_name, 'test2'));
        test2_name = s_name(:,contains(s_name, 'test2'));
    end
    if find(contains(s_name, 'test3')) ~= 0 
        test3 = s_avg(:,contains(s_name, 'test3'));
        test3_stim = s_stim_type(:,contains(s_name, 'test3'));
        test3_level = s_stim_level(:,contains(s_name, 'test3'));
        test3_name = s_name(:,contains(s_name, 'test3'));
    end
    if find(contains(s_name, 'test4')) ~= 0 
        test4 = s_avg(:,contains(s_name, 'test4'));
        test4_stim = s_stim_type(:,contains(s_name, 'test4'));
        test4_level = s_stim_level(:,contains(s_name, 'test4'));
        test4_name = s_name(:,contains(s_name, 'test4'));
    end
end
if exist('sh_name','var')
    if find(contains(sh_name, 'test1')) ~= 0 
        test1 = sh_avg(:,contains(sh_name, 'test1'));
        test1_stim = sh_stim_type(:,contains(sh_name, 'test1'));
        test1_level = sh_stim_level(:,contains(sh_name, 'test1'));
        test1_name = sh_name(:,contains(sh_name, 'test1'));
    end
    if find(contains(sh_name, 'test2')) ~= 0 
        test2 = sh_avg(:,contains(sh_name, 'test2'));
        test2_stim = sh_stim_type(:,contains(sh_name, 'test2'));
        test2_level = sh_stim_level(:,contains(sh_name, 'test2'));
        test2_name = sh_name(:,contains(sh_name, 'test2'));
    end
    if find(contains(sh_name, 'test3')) ~= 0 
        test3 = sh_avg(:,contains(sh_name, 'test3'));
        test3_stim = sh_stim_type(:,contains(sh_name, 'test3'));
        test3_level = sh_stim_level(:,contains(sh_name, 'test3'));
        test3_name = sh_name(:,contains(sh_name, 'test3'));
    end
    if find(contains(sh_name, 'test4')) ~= 0 
        test4 = sh_avg(:,contains(sh_name, 'test4'));
        test4_stim = sh_stim_type(:,contains(sh_name, 'test4'));
        test4_level = sh_stim_level(:,contains(sh_name, 'test4'));
        test4_name = sh_name(:,contains(sh_name, 'test4'));
    end
end    
if exist('mod_name','var')
    if find(contains(mod_name, 'test1')) ~= 0 
        test1 = mod_avg(:,contains(mod_name, 'test1'));
        test1_stim = mod_stim_type(:,contains(mod_name, 'test1'));
       test1_level = mod_stim_level(:,contains(mod_name, 'test1'));
        test1_name = mod_name(:,contains(mod_name, 'test1'));
        test1_peak = mod_peaks(:,contains(mod_name,'test1'));
        test1_valley = mod_valleys(:,contains(mod_name,'test1'));
    end
    if find(contains(mod_name, 'test2')) ~= 0 
        test2 = mod_avg(:,contains(mod_name, 'test2'));
        test2_stim = mod_stim_type(:,contains(mod_name, 'test2'));
        test2_level = mod_stim_level(:,contains(mod_name, 'test2'));
        test2_name = mod_name(:,contains(mod_name, 'test2'));
        test2_peak = mod_peaks(:,contains(mod_name,'test2'));
        test2_valley = mod_valleys(:,contains(mod_name,'test2'));
    end
    if find(contains(mod_name, 'test3')) ~= 0 
        test3 = mod_avg(:,contains(mod_name, 'test3'));
        test3_stim = mod_stim_type(:,contains(mod_name, 'test3'));
        test3_level = mod_stim_level(:,contains(mod_name, 'test3'));
        test3_name = mod_name(:,contains(mod_name, 'test3'));
        test3_peak = mod_peaks(:,contains(mod_name,'test3'));
        test3_valley = mod_valleys(:,contains(mod_name,'test3'));
    end
    if find(contains(mod_name, 'test4')) ~= 0 
        test4 = mod_avg(:,contains(mod_name, 'test4'));
        test4_stim = mod_stim_type(:,contains(mod_name, 'test4'));
        test4_level = mod_stim_level(:,contains(mod_name, 'test4'));
        test4_name = mod_name(:,contains(mod_name, 'test4'));
        test4_peak = mod_peaks(:,contains(mod_name,'test4'));
        test4_valley = mod_valleys(:,contains(mod_name,'test4'));
    end
end  

if (exist('test1', 'var') && contains(test1_name,'testbox')) || ...
        (exist('test2', 'var') && contains(test2_name,'testbox')) || ...
        (exist('test3', 'var') && contains(test3_name,'testbox')) || ...
        (exist('test4', 'var') && contains(test4_name,'testbox'))
    test = 'Test box';
else test = []; 
end

%testnames = who('-regexp', '_name');
%Plot ------------------
figure('units','normalized','position',[0.05 0.25 0.45 0.6]);
if exist('test1_peak', 'var')
    semilogx(freqs, test1_peak, 'LineStyle',':', 'color', [0 0.498 0], 'linewidth', 1.0);  hold on;
    t1peaklbl = [cell2mat(test1_stim) ' (' cell2mat(test1_level) ') peaks'];
else t1peaklbl = '';
end
if exist('test1','var')
    semilogx(freqs, test1, 'color', [0 0.498 0], 'linewidth', 1.5);  hold on;
    t1lbl = [cell2mat(test1_stim) ' (' cell2mat(test1_level) ')'];
else t1lbl = '';
end
if exist('test1_valley','var')
    semilogx(freqs, test1_valley, 'LineStyle',':', 'color', [0 0.498 0], 'linewidth', 1.0);  hold on;
    t1valleylbl = [cell2mat(test1_stim) ' (' cell2mat(test1_level) ') valleys'];
else t1valleylbl = '';
end
if exist('test2_peak','var')
    semilogx(freqs, test2_peak, 'LineStyle',':', 'color', [0.6 0.2 1], 'linewidth', 1.0);  hold on;
    t2peaklbl = [cell2mat(test2_stim) ' (' cell2mat(test2_level) ') peaks'];
else t2peaklbl = '';
end
if exist('test2','var')
    semilogx(freqs, test2, 'color', [0.6 0.2 1], 'linewidth', 1.5);  hold on;
    t2lbl = [cell2mat(test2_stim) ' (' cell2mat(test2_level) ')'];
else t2lbl = '';
end
if exist('test2_valley','var')
    semilogx(freqs, test2_valley, 'LineStyle',':', 'color', [0.6 0.2 1], 'linewidth', 1.0);  hold on;
    t2valleylbl = [cell2mat(test2_stim) ' (' cell2mat(test2_level) ') valleys'];
else t2valleylbl = '';
end
if exist('test3_peak','var')
    semilogx(freqs, test3_peak, 'LineStyle',':', 'color', [0 0.7 1.0], 'linewidth', 1.0);  hold on;
    t3peaklbl = [cell2mat(test3_stim) ' (' cell2mat(test3_level) ') peaks'];
else t3peaklbl = '';
end
if exist('test3','var')
    semilogx(freqs, test3, 'color', [0 0.7 1.0], 'linewidth', 1.5);  hold on;
    t3lbl = [cell2mat(test3_stim) ' (' cell2mat(test3_level) ')'];
else t3lbl = '';
end
if exist('test3_valley','var')
    semilogx(freqs, test3_valley, 'LineStyle',':', 'color', [0 0.7 1.0], 'linewidth', 1.0);  hold on;
    t3valleylbl = [cell2mat(test3_stim) ' (' cell2mat(test3_level) ') valleys'];
else t3valleylbl = '';
end
if exist('test4_peak','var')
    semilogx(freqs, test4_peak, 'LineStyle',':', 'color', [1 0.69 0.13], 'linewidth', 1.0);  hold on;
    t4peaklbl = [cell2mat(test4_stim) ' (' cell2mat(test4_level) ') peaks'];
else t4peaklbl = '';
end
if exist('test4','var')
    semilogx(freqs, test4, 'color', [1 0.69 0.13], 'linewidth', 1.5);  hold on;
    t4lbl = [cell2mat(test4_stim) ' (' cell2mat(test4_level) ')'];
else t4lbl = '';
end
if exist('test4_valley','var')
    semilogx(freqs, test4_valley, 'LineStyle',':', 'color', [1 0.69 0.13], 'linewidth', 1.0);  hold on;
    t4valleylbl = [cell2mat(test4_stim) ' (' cell2mat(test4_level) ') valleys'];
else t4valleylbl = '';
end
if exist('th_name', 'var')
    semilogx(audiofreqs(I), audioThresh(I),'b--', 'linewidth', 1); 
    thrlbl = th_name;
else thrlbl = '';
end
        
set(gca, 'XTick', [198 logspace(log10(250),log10(16000),19)], ...
    'XTickLabel', {'','250','','','500','','','1000','','','2000','','','4000','','','8000','','','16000'}, ...
    'YTick', -10:10:140, 'fontsize', 14, 'XGrid', 'on', 'XMinorTick', 'off', 'XMinorGrid', 'off', 'YGrid','on');
axis([160 17000 -12 148]);       
title(['Speechmap (' test ')'], 'fontsize', 22, 'Interpreter','none');
xlabel('freq (Hz)', 'fontsize', 18);
ylabel('dB SPL', 'fontsize', 18);
warning('off', 'MATLAB:legend:IgnoringExtraEntries')
lbls = {t1peaklbl; t1lbl; t1valleylbl; t2peaklbl; t2lbl; t2valleylbl; ...
    t3peaklbl; t3lbl; t3valleylbl; t4peaklbl; t4lbl; t4valleylbl; thrlbl};
lbls = [lbls(~cellfun('isempty',lbls)) ; 'MAP'];
MAP = [17.5 10.2 8.5 9.3 9.5 12.9 13.0 15.0 16.0 18.3 22.1 26.9]; 
semilogx(audiofreqs, MAP, 'k:');

% if exist('test2_peak')
%     semilogx(freqs, test2_peak, 'LineStyle',':', 'color', [0.6 0.2 1], 'linewidth', 1.0);  hold on;
%     semilogx(freqs, test2_valley, 'LineStyle',':', 'color', [0.6 0.2 1], 'linewidth', 1.0);  hold on;
% end
% if exist('test3_peak')
%     semilogx(freqs, test3_peak, 'LineStyle',':', 'color', [0 0.7 1.0], 'linewidth', 1.0);  hold on;
%     semilogx(freqs, test3_valley, 'LineStyle',':', 'color', [0 0.7 1.0], 'linewidth', 1.0);  hold on;
% end
% if exist('test4_peak')
%     semilogx(freqs, test4_peak, 'LineStyle',':', 'color', [1 0.69 0.13], 'linewidth', 1.0);  hold on;
%     semilogx(freqs, test4_valley, 'LineStyle',':', 'color', [1 0.69 0.13], 'linewidth', 1.0);  hold on;
% end
hLeg = legend(lbls, 'Location', 'Northwest');
hLeg.ItemHitFcn = @action1; 

% switch nargin
%     case 2
%         method = rawfile.session.test{1,13}.Attributes.method;
%         
%     case 1
%         c = a + a;
%     otherwise
%         c = 0;
% end









