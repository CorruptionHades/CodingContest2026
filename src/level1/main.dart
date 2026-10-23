import 'dart:io';

void main() async {
    File file = File("/home/corruptionhades/IdeaProjects/CodingContest2026/src/level1/level-1/zip/in_level-1_2-large.txt");
   // File file = File("/home/corruptionhades/IdeaProjects/CodingContest2026/src/level1/level-1/zip/in_level-1_1-small.txt");
   // File file = File("/home/corruptionhades/IdeaProjects/CodingContest2026/src/level1/level-1/zip/in_level-1_0-example.txt");

    String inFIleName = file.path.split("/").last;
    File outFile = File(file.parent.path + "${inFIleName}-out.txt");

    // clear out file
    outFile.writeAsStringSync("", mode: FileMode.write);

    String content = await file.readAsString();
    var lines = content.split("\n");

    List<int> seenNs = [];

    int nubmerOflines = -1;
    for(var line in lines) {
        int? n = int.tryParse(line);

        print(n);

        if(seenNs.contains(n)) {
            print("Already seen n : $n");
           // continue;
        }

        if(n == null) {
            print("error n not a number : $line");
            continue;
        }

        if(nubmerOflines == -1) {
            nubmerOflines = n;
            print("Number of lines : $nubmerOflines");
            continue;
        }

        seenNs.add(n);

        String out = "";

        int startMinuse = n;

        for(int reihe = 1; reihe <= 2*n+1; reihe++) {

            // anfang minuse
            int normalized = startMinuse.abs();
            for(int i = 1; i <= normalized; i++) {
                out += "-";
            }

            // reihenanfgan stern
            if(reihe != 1 && reihe != 2*n+1) {
                out += "*-";
            }
            else {
                out += "*";
            }

            // start stopp sternchen
            if(reihe == 1 || reihe == 2*n+1) {

                for(int j = 1; j <= n; j++) {
                    out += "-*";
                }
            }

            // nullen
            if(reihe != 1 && reihe != 2*n+1) {
                int anzahlNullen = 2*n-1-normalized;
                for(int k = 1; k <= anzahlNullen; k++) {
                    out += "O-";
                }
            }

            // reihen ende stern
            if(reihe != 1 && reihe != 2*n+1) {
                out += "*";
            }

            // end -
            for(int i = 1; i <= normalized; i++) {
                out += "-";
            }

            startMinuse--;
            out += "\n";
        }

        print(out);


        // write out
        outFile.writeAsStringSync(out, mode: FileMode.append);
        outFile.writeAsStringSync("\n", mode: FileMode.append);

        print("");
        print("");
        print("");
    }
}