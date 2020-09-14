using Plots

funcs=[sin,cos,sinh,cosh];

p = plot(funcs,-6,6,link=:both,layout=4,title=reshape(map(string,funcs),1,4),leg=false)

for i=1:2; plot!(p[i],xformatter=_->""); plot!(p[2i],yformatter=_->""); end; p
