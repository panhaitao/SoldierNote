
# 


## 

If you want to see the compiler/precompiler defines set by certain parameters, do this:
`gcc -march=native -E -v - </dev/null 2>&1 | grep cc1`
`echo | gcc -dM -E - -march=native`
