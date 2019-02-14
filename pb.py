trips = '''10 4 465
91 8 95
7 87 100
22 661 15
3 78 588
3 94 50
52 105 3
854 834 839
99 100 113
50 49 870
6 51 46
73 14 5
52 51 143
903 14 10
132 124 80
777 3 74
7 91 123
93 687 89
209 135 66
110 17 8
95 99 75'''

groups = []
for group in trips.split('\n'):
    items = group.split()
    groups.append([int(items[0]), int(items[1]), int(items[2])])

22,661,15

for num in groups:
    a = num[0]
    b = num[1]
    c = num[2]
    print(f"{a},{b},{c}", end='\n')
    if (a > b and a < c) or (a < b and a > c):
        print(a, end = ' ')
    elif (b > a and b < c) or (b < a and b > c):
        print(b, end = ' ')
    else:
        print(c, end = ' ')
    print("\n")
