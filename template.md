# HW 2

## Problem 99

My source code:

```verilog
//Filename: p1.sv
module....
...
alawys_ff @ ...begin
...
end

endmodule
```

My test bench:

```verilog
//Filename: p1_tb.sv
module....
...
alawys_ff @ ...begin
...
end

endmodule
```

Results:
```
time: 10 a: 10 b: 10...
time: 20 a: 11 b: 10...
time: 30 a: 11 b: 10...
```

We expect $\sum homework = 100$

Screenshot:

![screenshot of](media/placeholder.png)

Schematic (RTL View):
    
<img src=media/placeholder.svg width=400px>


## Appendix 


Note that on many linux systems a document converter, pandoc, can be used to render this file as an html file, which can with further effort be converted to other formats including PDF.

```bash
pandoc template.md -o template.html --standalone
```


