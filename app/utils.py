"""
Some useful functions
"""

def flatten(a_list):
    # TODO: refactor function - is ugly
    flat_list = []
    # Iterate through the outer list
    if type(a_list) is list:
        for element in a_list:
            if type(element) is list:
                # If the element is of type list, iterate through the sublist
                for item in element:
                    flat_list.append(item)
            else:
                flat_list.append(element)
    else:
        flat_list.append(a_list)
    return flat_list
