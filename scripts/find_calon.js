const fs = require('fs');
const content = fs.readFileSync('D:\\MobileAppDev\\FYPExpoHub\\lib\\core\\data\\excel_data.dart', 'utf8');
const lines = content.split('\n');
const matrics = ['2023414614','2023260244','2023240232','2023436724','2023240168','2023239276','2023820446','2023699244','2023674486','2023260928'];

for (const m of matrics) {
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes("'" + m + "'")) {
      let id = '?', booth = '?', name = '?';
      for (let j = Math.max(0, i - 8); j <= i + 8 && j < lines.length; j++) {
        const idMatch = lines[j].match(/"id": '([^']+)'/);
        if (idMatch) id = idMatch[1];
        const bm = lines[j].match(/"booth_number": '([^']+)'/);
        if (bm) booth = bm[1];
        const nm = lines[j].match(/"team_display_names": \['([^']+)'\]/);
        if (nm) name = nm[1];
      }
      console.log(m + ' | ' + id + ' | ' + booth + ' | ' + name);
      break;
    }
  }
}
