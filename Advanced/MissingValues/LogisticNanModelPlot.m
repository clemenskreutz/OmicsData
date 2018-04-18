
function LogisticNanModelPlot(out)

t = out.type(:,1);
b1 = out.b(t==1,:);
b2 = out.b(t==2,:);
b3 = out.b(t==3,:);
b3s = sort(mean(b3,2));

figure
boxplot(b2')
figure
subplot(1,2,1)
plot(1:length(b3),b3s)
xlabel('# of row')
ylabel('b: log reg coeff for row')
subplot(1,2,2)
histogram(b3s)
xlabel('b')
ylabel('Frequency')