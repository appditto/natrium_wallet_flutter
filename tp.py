def median(input_list):
    # sort list
    sorted_list = sorted(input_list)
    # If list has odd number of elements, take middle
    if len(sorted_list) % 2 != 0:
        return sorted_list[len(sorted_list) // 2]
    else:
        # even number of elements gets average of middle two values
        middle_one = sorted_list[len(sorted_list) // 2]
        middle_two = sorted_list[len(sorted_list) // 2 - 1]
        return (middle_one + middle_two) / 2

# with odd number of elements
print(median([1,3,5]))
print(median([5,4,9]))

# with even number of elements
print(median([1,3,3,7]))
print(median([7,3,9,4]))
