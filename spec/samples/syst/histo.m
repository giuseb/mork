d = dir('*.txt');

for i=1:length(d)
   filename = d(i).name;
   f = fopen(filename,'r');
   ink = textscan(f, 'ink:%f', 1);
   drk = textscan(f, 'drk:%f', 1);
   pap = textscan(f, 'pap:%f', 1);
   cal = textscan(f, 'cal:%f', 1);
   cho = textscan(f, 'cho:%f', 1);
    
   ink = ink{1};
   drk = drk{1};
   pap = pap{1};
   cal = cal{1};
   cho = cho{1};
   
   s = sprintf('%s --> ink %.1f, drk %.1f, pap %.1f, cal %.1f, cho %.1f', filename, ink, drk, pap, cal, cho);
   disp(s);
   
   if ink > 240
      disp('invalid ink')
      continue
   end
   
   dA = textscan(f, '%f');
   fclose(f);
   data = dA{1};
   
   hold off
   edgehist(data, 0:5:255)
   set(gca, 'xlim', [ink 255])
   ylim = get(gca, 'ylim');
   hold on
   
    
   line([drk drk], ylim, 'color', 'k');
   line([pap pap], ylim, 'color', 'y');
   line([cal cal], ylim, 'color', 'r');
   line([cho cho], ylim, 'color', 'b');
   pause
end
