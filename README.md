# README: Mihut Maria-Emilia 311CA

---

## Problem 1: sortari.asm

### Problem Description

The `sort` function takes two parameters:
- `n`: number of nodes in the input array.
- `nod`: pointer to an array of nodes, each with:
  - a 4-byte integer `val`
  - a 4-byte pointer `next`

It constructs a singly linked list by linking nodes in ascending order of their `val` fields (1 to `n`). The `next` pointer of each node points to the node with the next higher `val`. The last node’s `next` is set to `NULL`.

The input array contains exactly one node for each value from 1 to `n`.

---

### Algorithm Overview

1. **Initialize** `head` and `current` pointers to `NULL`; set `val_curent = 1`.
2. For each `val_curent` in [1..n]:
   - Seaerch `nod` array for node with `val == val_curent`.
   - If first node, set `head` and `current` to this node.
   - Else, link node after `current` and update `current`.
3. After loop, if list not empty, set `current->next = NULL`.
4. Return `head`.

---

### Registers and Stack Usage

- `ebp`: Stack frame base pointer, used to access function parameters and local variables.  
- `ecx`: Holds the parameter `n` (number of nodes).  
- `esi`: Pointer to the array of nodes (`nod`).  
- `edi`: Pointer to the head of the constructed linked list (`head`), initialized to `NULL`.  
- `ebx`: Pointer to the current node in the linked list (`current`), initialized to `NULL`.  
- `edx`: Stores the current value being searched for (`val_curent`), starts at 1.  
- `eax`: Used as an indx to traverse the node array and as temporary storage.  

The stack frame is set up with `enter 0,0`. Parameters are accessed via `[ebp+8]` (`n`) and 
`[ebp+12]` (`nod`). The function iterates through the node array searching for nodes with incremental 
`val` 
values, linking them accordingly. Proper register presrvation and stack cleanup are performed before 
return.

---

### Equivalent C Code

```c
struct node {
    int val;
    struct node* next;
};

struct node* sort(int n, struct node* nod) {
    struct node* head = NULL;
    struct node* current = NULL;

    for (int val_curent = 1; val_curent <= n; val_curent++) {
        for (int i = 0; i < n; i++) {
            if (nod[i].val == val_curent) {
                if (!head) {
                    head = &nod[i];
                    current = head;
                } else {
                    current->next = &nod[i];
                    current = &nod[i];
                }
                break;
            }
        }
    }

    if (current)
        current->next = NULL;

    return head;
}
```
## Problem 2: operatii.asm

### Problem Description

The program implements three functions:

- `get_words`: Splits a null-terminated string into words separated by delimiters (`space`, `comma`, 
`period`, `newline`), storing pointers to each word in an array.
- `sort`: Sorts the array of word pointers by word length (ascending), then alphabetically for words 
with equal length, using the standard C library `qsort` function with a custom `comparator`.
- `comparator`: Compares two words by length first, and if equal, compares them alphabetically using 
`strcmp`.

---

### Algorithm Breakdown

1. **Initialization**  
   Load parameters: string pointer `s`, pointer to words array `words`, and maximum 
   `number_of_words`. Initialize word count (`ebx`) and in-word flag (`edx`) to zero.

2. **Main Loop**  
   Iterate through each character of `s`:  
   - If current character is a delimiter (`space`, `comma`, `period`, or `newline`):  
     - If inside a word, null-terminate it by replacing delimiter with `'\0'` and clear in-word 
     flag.  
   - Otherwise (non-delimiter):  
     - If not inside a word, store currrent pointer into `words[word_count]`, increment word count, 
     set in-word flag.  
   - Stop when reaching null terminator or maximum word count.

3. **Final Word Handling**  
   If string ends while inside a word and word count is less than max, null-terminate the last word 
   and increment word count.

4. **Return**  
   Function returns with the `words` array populated with pointers to the extracted words.

---

### Registers and Stack Usage

- `ebp`: Stack frame base pointer  
- `esi`: Pointer to string `s` (in `get_words`), or to string `*a` (in `comparator`), or to `words` 
array (in `sort`)  
- `edi`: Pointer to `words` array (in `get_words` and `sort`), or to string `*b` (in `comparator`)  
- `ebx`: Word count (in `get_words`), length of `*a` (in `comparator`)  
- `edx`: In-word flag (in `get_words`), length of `*b` (in `comparator`)  
- `ecx`: Maximum or actual number of words (in `get_words` and `sort`)  
- `eax`: Temporary register for return values and indexing  

Stack frame is set up with `enter 0,0`. Parmeters accessed at `[ebp+8]`, `[ebp+12]`, `[ebp+16]`. 

---

### Equivalent C Code

```c
int comparator(const void *a, const void *b) {
    const char *str_a = *(const char **)a;
    const char *str_b = *(const char **)b;
    int len_a = strlen(str_a);
    int len_b = strlen(str_b);
    if (len_a != len_b)
        return len_a - len_b;
    return strcmp(str_a, str_b);
}

void sort(char **words, int number_of_words, int size) {
    qsort(words, number_of_words, size, comparator);
}

void get_words(char *s, char **words, int number_of_words) {
    int word_count = 0;
    int in_word = 0;
    char *current = s;

    while (*current && word_count < number_of_words) {
        if (*current == ' ' || *current == ',' || *current == '.' || *current == '\n') {
            if (in_word) {
                *current = '\0';
                in_word = 0;
            }
        } else {
            if (!in_word) {
                words[word_count++] = current;
                in_word = 1;
            }
        }
        current++;
    }

    if (in_word && word_count < number_of_words) {
        *current = '\0';
        word_count++;
    }
}
```
## Problem 3: kfib.asm

### Problem Description

The `kfib` function computes the *k*-Fibonacci number for given integers `n` and `k` according to the 
following definition:

- If `n < k`, then `kfib(n, k) = 0`
- If `n == k` then `kfib(n, k) = 1`
- If `n > k + 1`, then  
  `kfib(n, k) = kfib(n-1, k) + kfib(n-2, k) + ... + kfib(n-k, k)`

However, for an optimisation and for a simpler code (i know it was not necessary but it was easier 
for me to implement and debug), we simplify the formula for `kfib(n,k)`.

We know that `kfib(n-1, k) = kfib(n-2, k) + kfib(n-3, k) + ... + kfib(n-1-k, k)` so 
`kfib(n-2, k) + kfib(n-3, k) + ... + kfib(n-k, k) = kfib(n-1, k) - kfib(n-1-k, k)`.

Now if we write `kfib(n, k)` again, we have a new frmula that is much faster:
`kfib(n, k) = kfib(n-1, k) + (kfib(n-1, k) - kfib(n-1-k, k))= 2 * kfib(n-1, k) - kfib(n-1-k, k)`.

This results in having a new basecase, if `n-1-k == 0`, equivalent to `n ==  k + 1`.
If we calculate this with the original formula, we notice that 
`kfib(k + 1, k) = kfib(k, k) + kfib(k - 1, k) + ... kfib(0, k) = 1 + 0 + ... + 0 = 1`, so we put it 
in the same category as the test-case `n == k`.

---

### Algorithm Breakdown

1. **Initialization**  
   - Set up stack frame and save registers `ebx`, `edx`.  
   - Load parameters `n` and `k` from the stack into registers `ebx` and `edx`.

2. **Base Cases**  
   - If `n < k`, return `0`.  
   - If `n == k` or `n == k + 1`, return `1`.

3. **Recursive Case**  
   - Compute `kfib(n-1, k)` recursively:  
     - Push parameters (`k`, `n-1`), call `kfib`.  
     - Multiply the returned result by 2 and store in `edi`.  
   - Compute `kfib(n-k-1, k)` recursively:  
     - Push parameters (`k`, `n-k-1`), call `kfib`.  
   - Compute final result:  
     - `kfib(n, k) = 2 * kfib(n-1, k) - kfib(n-k-1, k)`  
   - Return the result in `eax`.

4. **Cleanup**  
   - Restore registers and stack frame before returning.

---

### Registers and Stack Usage
### Registers and Stack Usage

- `ebp`: Stack frame base pointer, used for structured access to function parameters and local 
variables.  
- `ebx`: Holds the input parameter `n` and is used for intermediate calculations.  
- `edx`: Holds the input parameter `k` and is used during recursive calls.  
- `ecx`: Used as a temporary register to clculate `n-1` and `n-k-1` for recursive calls.  
- `edi`: Temporarily stores the value of `2 * kfib(n-1, k)` during recursion.  
- `eax`: Used to hold return values from recursive calls and intermediate computations.  

Stack frame is created with `enter 0,0`. Parameters accessed relative to `ebp` at `[ebp+8]` and 
`[ebp+12]`. Recursive calls pass parameters on stack.

---

### Equivalent C Code

```c
int kfib(int n, int k) {
    if (n < k)
        return 0;
    if (n == k || n == k + 1)
        return 1;
    return 2 * kfib(n - 1, k) - kfib(n - k - 1, k);
}
```
## Problem 4: composite_palindrome.asm

### Problem Description

The program implements three functions:

- `check_palindrome`:  
  Checks if a given string of length `n` is a palindrome (returns 1 if yes, 0 otherwise).

- `composite_palindrome`:  
  Given an array of up to 15 strings and their count, generates all possible concatenations of 
  subsets of these strings (using a 15-bit mask to select which strings to concatenate), finds the 
  longest concatenated string that forms a palindrome, and returns a pointer to that longest 
  palindrome string.

- `compare_str`:  
  Compares two strings and returns:  
  - 1 if the frst string is longer, or lexicographically smaller if lengths equal,  
  - -1 if the second string is better by those criteria,  
  - 0 if they are equal.

The function `composite_palindrome` uses dynamic memory allocation for buffers, string concatenation, 
palindrome checking, and lexicographical comparison to identify and return the best palindrome formed.

---

### Algorithm Breakdown

1. **check_palindrome**  
   - Input: string pointer and length.  
   - Compares characters from start and end moving inward.  
   - Returns 1 if palindrome, 0 otherwise.

2. **composite_palindrome**  
   - Input: array of up to 15 strings and count.  
   - Allocates two 155-byte buffers: `longest_palindrome` and `candidate`.  
   - Iterates over all non-empty subsets of strings (mask from 32767 down to 1):  
     - Builds `candidate` by concatenating strings selected by mask bits.  
     - Skips empty candidates.  
     - Checks if `candidate` is palindrome.  
     - If palindrome, compares with current `longest_palindrome` using `compare_str`.  
     - Updates `longest_palindrome` if `candidate` is better (longer or lex smaller if equal 
     length).  
   - Frees `candidate` buffer and returns pointer to `longest_palindrome`.

3. **compare_str**  
   - Compares lengths first; longer string is "better".  
   - If lengths equal, lexicographically smaller string is "better".  
   - Returns 1 if first string better, -1 if second better, 0 if equal.

---

### Registers and Stack Usage

- `ebp`: Stack frame base pointer, used to access function parameters and local variables.  
- `esi`: Pointer to the array of strings (`char **strs`), used for indexing strings during 
concatenation.  
- `eax`: Holds the number of strings (`count`), also used as a tmporary register for function return 
values and intermediate calculations.  
- `edi`: Pointer to the dynamically allocated buffer for the longest palindrome found 
(`longest_palindrome`).  
- `ebx`: Pointer to the dynamically allocated candidate buffer used to build concatenated strings 
(`candidate`).  
- `edx`: 15-bit mask controlling which strings from the array are concatenated in each iteration; 
decremented to enumerate all subsets.  
- `ecx`: Loop index register used to iterate over up to 15 strings and as a temporary storage for 
string lengths and counters.

The stack frame is set up with `enter 0,0`, and function parameters are accessed via `[ebp+8]` 
(pointer to strings array) and `[ebp+12]` (number of strings).

Functions `malloc`, `free`, `strcat`, `strcpy`, `strlen`, `strcmp` are externally linked.

---

### Equivalent C Code

```c
#include <stdlib.h>
#include <string.h>

int check_palindrome(const char *str, int len) {
    for (int i = 0; i < len / 2; i++) {
        if (str[i] != str[len - 1 - i]) return 0;
    }
    return 1;
}

int compare_str(const char *str1, const char *str2) {
    int len1 = strlen(str1);
    int len2 = strlen(str2);
    if (len1 > len2) return 1;
    if (len1 < len2) return -1;
    int cmp = strcmp(str1, str2);
    if (cmp < 0) return 1;
    if (cmp > 0) return -1;
    return 0;
}

char* composite_palindrome(char **strs, int count) {
    char *longest_palindrome = malloc(155);
    longest_palindrome[0] = '\0';

    char *candidate = malloc(155);
    int mask = (1 << 15) - 1; // 32767

    while (mask > 0) {
        candidate[0] = '\0';
        for (int i = 0; i < 15; i++) {
            if ((mask >> i) & 1) {
                strcat(candidate, strs[i]);
            }
        }

        if (candidate[0] != '\0') {
            int len = strlen(candidate);
            if (check_palindrome(candidate, len)) {
                if (compare_str(candidate, longest_palindrome) > 0) {
                    strcpy(longest_palindrome, candidate);
                }
            }
        }

        mask--;
    }

    free(candidate);
    return longest_palindrome;
}
```