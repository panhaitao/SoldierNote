gcc（gnu collect compiler）是一组编译工具的总称。它主要完成的工作任务是“预处理”和“编译”，以及提供了与编译器紧密相关的运行库的支持，如libgcc_s.so、libstdc++.so等。
Gcc specs

gcc spec文件是用来控制gcc的默认行为的可以通过这个命令来打印gcc spec:

 # gcc -dumpspecs

如果希望使用自己的specs, 可以通过-specs参数来指定：

 # g++ -O2 -specs=/tmp/specs 1.c

If you want to see the compiler/precompiler defines set by certain parameters, do this:
`gcc -march=native -E -v - </dev/null 2>&1 | grep cc1`
`echo | gcc -dM -E - -march=nativ
