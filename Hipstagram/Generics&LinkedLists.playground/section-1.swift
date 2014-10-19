// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


class LinkedList <T> {
  var head: Node <T>?
  
  func insert(value: T) {
    // 0th case if list is empty
    if head == nil {
      var node = Node<T>()
      node.value = valueb
      node.next = nil
      head = node
      return
    }
    
    // Otherwise, walk the list
    var currentNode = head
    while currentNode?.next != nil {
      currentNode = currentNode?.next
    }
    
    var node = Node<T>()
    node.value = value
    node.next = nil
    
    currentNode?.next = node
  }
