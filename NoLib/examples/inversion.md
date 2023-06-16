$$\begin{bmatrix}
.  \\
.  \\
.\end{bmatrix}
\begin{bmatrix}
I-G'_\mu  & - G'_x    & - G'_y   \\
0         & I - T'_x  & - T'_y   \\
A'_\mu    &  A'_x     &   A'_y
\end{bmatrix}
\begin{bmatrix}
I  & 0    & 0   \\
0         & I  & 0 \\
0    &  0   &  I
\end{bmatrix}$$

$$\begin{bmatrix}
L_1 \leftarrow (I-G'_\mu)^{-1}  L_1 \\
.  \\
.\end{bmatrix}
\begin{bmatrix}
I  & -  (I-G'_\mu)^{-1} G'_x    & -  (I-G'_\mu)^{-1} G'_y   \\
0         & I - T'_x  & - T'_y   \\
A'_\mu    &  A'_x     &   A'_y
\end{bmatrix}
\begin{bmatrix}
 (I-G'_\mu)^{-1} & 0    & 0   \\
0         & I  & 0 \\
0    &  0   &  I
\end{bmatrix}$$

$$\begin{bmatrix}
  \\
.  \\
L_3 \leftarrow L_3 - A'_\mu L_1\end{bmatrix}
\begin{bmatrix}
I  & -  (I-G'_\mu)^{-1} G'_x    & -  (I-G'_\mu)^{-1} G'_y   \\
0         & I - T'_x  & - T'_y   \\
0         &  A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x   &   A'_y + A'_\mu  (I-G'_\mu)^{-1} G'_y
\end{bmatrix}
\begin{bmatrix}
 (I-G'_\mu)^{-1} & 0    & 0   \\
0         & I  & 0 \\
-A'_\mu  (I-G'_\mu)^{-1}    &  0   &  I
\end{bmatrix}$$

$$\begin{bmatrix}
  \\
L_2 \leftarrow (I-T'_x)^{-1} L_2 \\
.
\end{bmatrix}
\begin{bmatrix}
I  & -  (I-G'_\mu)^{-1} G'_x    & -  (I-G'_\mu)^{-1} G'_y   \\
0         & I  & - (I - T'_x)^{-1} T'_y   \\
0         &  A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x   &   A'_y + A'_\mu  (I-G'_\mu)^{-1} G'_y
\end{bmatrix}
\begin{bmatrix}
 (I-G'_\mu)^{-1} & 0    & 0   \\
0         & (I - T'_x)^{-1}  & 0 \\
-A'_\mu  (I-G'_\mu)^{-1}    &  0   &  I
\end{bmatrix}$$

$$\begin{bmatrix}
L_1 \leftarrow L_1 +  (I-G'_\mu)^{-1} G'_x L_2  \\
 \\
L_3 \leftarrow L_3 -  \left(A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x \right) L_2 
\end{bmatrix}
\begin{bmatrix}
I  & 0  & - (I-G'_\mu)^{-1} G'_y - (I-G'_\mu)^{-1} G'_x  (I - T'_x)^{-1} T'_y \\
0         & I  & - (I - T'_x)^{-1} T'_y   \\
0         & 0  &   \underbrace{A'_y + A'_\mu  (I-G'_\mu)^{-1} G'_y +  \left( A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x \right) (I - T'_x)^{-1} T'_y }_{J_y}
\end{bmatrix}
\begin{bmatrix}
 (I-G'_\mu)^{-1} &  (I-G'_\mu)^{-1} G'_x (I-T'_x)^{-1}   & 0   \\
0         & (I - T'_x)^{-1}  & 0 \\
-A'_\mu  (I-G'_\mu)^{-1}    &  -\left(A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x \right)(I - T'_x)^{-1}     &  I
\end{bmatrix}$$


$$\begin{bmatrix}
 \\
 \\
L_3 \leftarrow J_y^{-1} L_3 
\end{bmatrix}
\begin{bmatrix}
I  & 0  & - (I-G'_\mu)^{-1} G'_y - (I-G'_\mu)^{-1} G'_x  (I - T'_x)^{-1} T'_y \\
0         & I  & - (I - T'_x)^{-1} T'_y   \\
0         & 0  & I
\end{bmatrix}
\begin{bmatrix}
 (I-G'_\mu)^{-1} &  (I-G'_\mu)^{-1} G'_x (I-T'_x)^{-1}   & 0   \\
0         & (I - T'_x)^{-1}  & 0 \\
-J_y^{-1} A'_\mu  (I-G'_\mu)^{-1}    &  - J_y^{-1} \left(A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x \right)(I - T'_x)^{-1}     &  J_y^{-1}
\end{bmatrix}$$



$$\begin{bmatrix}
L_1 \leftarrow L_1+ \left(  (I-G'_\mu)^{-1} G'_y - (I-G'_\mu)^{-1} G'_x  (I - T'_x)^{-1} T'_y  \right) L_3 \\
L_2 \leftarrow L_2+ (I-T'_x)^{-1} T'_y L_3 \\
.
\end{bmatrix}
\begin{bmatrix}
I  & 0  & 0\\
0         & I  & 0 \\
0         & 0  & I
\end{bmatrix}\\
\begin{bmatrix}
 (I-G'_\mu)^{-1} -\left(  (I-G'_\mu)^{-1} G'_y - (I-G'_\mu)^{-1} G'_x  (I - T'_x)^{-1} T'_y  \right) J_y^{-1} A'_\mu  (I-G'_\mu)^{-1} &  (I-G'_\mu)^{-1} G'_x (I-T'_x)^{-1} - \left(  (I-G'_\mu)^{-1} G'_y - (I-G'_\mu)^{-1} G'_x  (I - T'_x)^{-1} T'_y  \right) J_y^{-1} \left(A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x \right)(I - T'_x)^{-1}   &  \left(  (I-G'_\mu)^{-1} G'_y - (I-G'_\mu)^{-1} G'_x  (I - T'_x)^{-1} T'_y  \right) J_y^{-1 }  \\
 -(I-T'_x)^{-1} T'_y  J_y^{-1} A'_\mu  (I-G'_\mu)^{-1}         & (I - T'_x)^{-1} - (I-T'_x)^{-1} T'_y J_y^{-1} \left(A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x \right)(I - T'_x)^{-1} &  (I-T'_x)^{-1} T'_y J_y^{-1 }  \\
-J_y^{-1} A'_\mu  (I-G'_\mu)^{-1}    &  - J_y^{-1} \left(A'_x + A'_\mu  (I-G'_\mu)^{-1} G'_x \right)(I - T'_x)^{-1}     &  J_y^{-1}
\end{bmatrix}$$
