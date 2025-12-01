def read_input():
    with open('input.txt') as f:
        for line in f:
            n = int(line[1:])
            if line[0] == 'L':
                n = -n
            yield n

def num_clicks(x):
    return int((abs(x-50)+50)/100)

def get_passwords():
    current = 50
    count1 = 0
    count2 = 0
    for d in read_input():
        if d < 0 and current == 0:
            current += 100  # Edge case if left turn on 0
        current = current + d
        count2 += num_clicks(current)
        current = current % 100
        if current == 0:
            count1 += 1
    return (count1, count2)

def main():
    a, b = get_passwords()
    print(f'Part 1: {a}')
    print(f'Part 2: {b}')

if __name__ == '__main__':
    main()
