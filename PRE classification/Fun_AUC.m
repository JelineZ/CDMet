% Calculate the AUC value,test_targets is the original sample labels,output is the labels obtained by the classifier

function [auc]=Fun_AUC(test_targets,output)

[~,I]=sort(output);  

M=0;N=0;

for i=1:length(output)

if(test_targets(i)==1)

M=M+1;  % M£ºNumber of observations in category 1
else

N=N+1;   % N£ºNumber of observations in category 0

end

end

sigma=0;

for i=M+N:-1:1

if(test_targets(I(i))==1)

sigma=sigma+i;

end

end

auc=(sigma-(M+1)*M/2)/(M*N);
end

