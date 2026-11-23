#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

int main() {
    int n, val;
    scanf("%d", &n); // Read the number of nodes

    struct Node *head = NULL, *tail = NULL;
    for (int i = 0; i < n; i++) {
        scanf("%d", &val); // Read each node value
        struct Node* newNode = malloc(sizeof(struct Node));
        newNode->data = val;
        newNode->next = NULL;
        if (!head) {
            head = tail = newNode; // Initialize head
        } else {
            tail = tail->next = newNode; // Append to the list
        }
    }

    // Use slow and fast pointers to find the middle
    struct Node *slow = head, *fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
    }

    // Reverse the second half of the list starting from the middle
    struct Node *prev = NULL, *next;
    while (slow) {
        next = slow->next;
        slow->next = prev;
        prev = slow;
        slow = next;
    }

    // Compare the first half with the reversed second half
    struct Node *p1 = head, *p2 = prev;
    while (p2) {
        if (p1->data != p2->data) {
            printf("False\n"); // Mismatch found
            return 0;
        }
        p1 = p1->next;
        p2 = p2->next;
    }

    printf("True\n"); // All nodes matched
    return 0;
}