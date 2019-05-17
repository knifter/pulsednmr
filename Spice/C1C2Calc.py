
from math import sqrt, pow

L = 26E-6
r = 7.0
w = 15E6
Z0 = 50.0

C1 = r / (sqrt(r*w*w*Z0*((L*L)*(w*w) + r*r - r*Z0)))
C2_num = (L*w**2*Z0) + sqrt((L**2)*r*(w**4)*Z0 + (L**2)*(w**4)*(Z0**2)+(r**3)*(w**2)*Z0)
C2_div = (L*L)*(w**4)*Z0 + (r*r)*(w*w)*Z0
C2 = C2_num / C2_div

print("C1 = ", C1)
print("C2_n = ", C2_num)
print("C2_d = ", C2_div)
print("C2 = ", C2)
