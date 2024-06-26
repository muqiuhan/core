// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

struct Cont[T] {
  content : T
  mut next : Cell[T]
}

enum Cell[T] {
  Nil
  Cons(Cont[T])
}

struct Queue[T] {
  mut length : Int
  mut first : Cell[T]
  mut last : Cell[T]
}

/// Creates a new empty queue.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::new()
/// ```
pub fn Queue::new[T]() -> Queue[T] {
  { length: 0, first: Nil, last: Nil }
}

test "new" {
  let queue : Queue[Int] = new()
  @assertion.assert_eq(queue.length, 0)?
}

/// Creates a new queue from an array.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::from_array([1, 2, 3, 4])
/// ```
pub fn Queue::from_array[T](arr : Array[T]) -> Queue[T] {
  if arr.length() == 0 {
    return new()
  }
  let queue : Queue[T] = Queue::new()
  queue.length = arr.length()
  for i = arr.length(); i > 0; i = i - 1 {
    let cell : Cell[T] = Cons({ content: arr[i - 1], next: queue.first })
    queue.first = cell
  }
  queue.last = queue.first
  queue
}

/// Tests if two queue cells are equal.
pub fn op_equal[T : Eq](self : Cell[T], other : Cell[T]) -> Bool {
  loop self, other {
    Nil, Nil => true
    Cons({ content: x, next: xs }), Cons({ content: y, next: ys }) => {
      if x != y {
        break false
      }
      continue xs, ys
    }
    _, _ => false
  }
}

test "from_array" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  let queue2 : Queue[Int] = Queue::[1]
  @assertion.assert_eq(queue.length, 4)?
  @assertion.assert_eq(queue.pop_exn(), 1)?
  @assertion.assert_eq(queue.pop_exn(), 2)?
  @assertion.assert_eq(queue.pop_exn(), 3)?
  @assertion.assert_eq(queue.pop_exn(), 4)?
  @assertion.assert_eq(queue2.pop_exn(), 1)?
  @assertion.assert_eq(queue2.length, 0)?
}

/// Clears the queue.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::[1, 2, 3, 4]
/// queue.clear()
/// ```
pub fn clear[T](self : Queue[T]) -> Unit {
  self.length = 0
  self.first = Nil
  self.last = Nil
}

test "clear" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.length, 4)?
  queue.clear()
  @assertion.assert_eq(queue.length, 0)?
}

pub fn length[T](self : Queue[T]) -> Int {
  self.length
}

/// Checks if the queue is empty.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::new()
/// let is_empty = queue.is_empty()
/// ```
pub fn is_empty[T](self : Queue[T]) -> Bool {
  self.length == 0
}

test "is_empty" {
  let queue : Queue[Int] = new()
  @assertion.assert_true(queue.is_empty())?
  queue.push(1)
  queue.push(2)
  queue.push(3)
  queue.push(4)
  @assertion.assert_false(queue.is_empty())?
}

/// Adds a value to the queue.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::new()
/// queue.add(1)
/// ```
pub fn push[T](self : Queue[T], x : T) -> Unit {
  let cell : Cell[T] = Cons({ content: x, next: Nil })
  match self.last {
    Nil => {
      self.length = 1
      self.first = cell
      self.last = cell
    }
    Cons(last) => {
      last.next = cell
      self.length = self.length + 1
      self.last = cell
    }
  }
}

test "push" {
  let queue : Queue[Int] = Queue::new()
  queue.push(1)
  queue.push(2)
  queue.push(3)
  queue.push(1)
  @assertion.assert_eq(queue.length, 4)?
  @assertion.assert_eq(queue.pop_exn(), 1)?
  @assertion.assert_eq(queue.pop_exn(), 2)?
  @assertion.assert_eq(queue.pop_exn(), 3)?
  @assertion.assert_eq(queue.pop_exn(), 1)?
}

/// Peeks at the first value in the queue.
/// 
/// Panics if the queue is empty.
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::[1, 2, 3, 4]
/// let first = queue.peek_exn()
/// ```
pub fn peek_exn[T](self : Queue[T]) -> T {
  match self.first {
    Nil => abort("Queue is empty")
    Cons(first) => first.content
  }
}

test "peek_exn" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.peek_exn(), 1)?
  @assertion.assert_eq(queue.length, 4)?
  @assertion.assert_eq(queue.pop_exn(), 1)?
  @assertion.assert_eq(queue.peek_exn(), 2)?
  @assertion.assert_eq(queue.length, 3)?
}

/// Peeks at the first value in the queue, which returns None if the queue is empty.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::[1, 2, 3, 4]
/// let first = queue.peek()
/// ```
pub fn peek[T](self : Queue[T]) -> Option[T] {
  match self.first {
    Nil => None
    Cons(first) => Some(first.content)
  }
}

test "peek" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.peek(), Some(1))?
  queue.clear()
  @assertion.assert_eq(queue.peek(), None)?
}

/// Pops the first value from the queue.
/// 
/// Panics if the queue is empty.
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::[1, 2, 3, 4]
/// let first = queue.pop_exn()
/// ```
pub fn pop_exn[T](self : Queue[T]) -> T {
  match self.first {
    Nil => abort("Queue is empty")
    Cons({ content, next: Nil }) => {
      self.clear()
      content
    }
    Cons({ content, next }) => {
      self.length = self.length - 1
      self.first = next
      content
    }
  }
}

test "pop_exn" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.pop_exn(), 1)?
  @assertion.assert_eq(queue.pop_exn(), 2)?
  @assertion.assert_eq(queue.pop_exn(), 3)?
  @assertion.assert_eq(queue.pop_exn(), 4)?
  @assertion.assert_eq(queue.length, 0)?
}

/// Pops the first value from the queue, which returns None if the queue is empty.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::[1, 2, 3, 4]
/// let first = queue.pop()
/// ```
pub fn pop[T](self : Queue[T]) -> Option[T] {
  if self.length == 0 {
    None
  } else {
    Some(self.pop_exn())
  }
}

test "pop" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.pop(), Some(1))?
  @assertion.assert_eq(queue.pop(), Some(2))?
  @assertion.assert_eq(queue.pop(), Some(3))?
  @assertion.assert_eq(queue.pop(), Some(4))?
  @assertion.assert_eq(queue.pop(), None)?
}

/// Iterates over the queue.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::[1, 2, 3, 4]
/// queue.iter(fn(x) { print(x) })
/// ```
pub fn iter[T](self : Queue[T], f : (T) -> Unit) -> Unit {
  loop self.first {
    Cons({ content, next }) => {
      f(content)
      continue next
    }
    Nil => ()
  }
}

test "iter" {
  let queue : Queue[Int] = new()
  let mut sum = 0
  queue.iter(fn(x) { sum = sum + x })
  @assertion.assert_eq(sum, 0)?
  queue.push(1)
  queue.push(2)
  queue.push(3)
  queue.push(4)
  sum = 0
  queue.iter(fn(x) { sum = sum + x })
  @assertion.assert_eq(sum, 10)?
}

/// Folds over the queue.
/// 
/// # Example
/// ```
/// let queue : Queue[Int] = Queue::[1, 2, 3, 4]
/// let sum = queue.fold(0, fn(acc, x) { acc + x })
/// ```
pub fn fold[T](self : Queue[T], ~init : T, f : (T, T) -> T) -> T {
  loop self.first, init {
    cell, acc =>
      match cell {
        Nil => acc
        Cons({ content, next }) => continue next, f(acc, content)
      }
  }
}

test "fold" {
  let queue : Queue[Int] = new()
  let sum = queue.fold(~init=0, fn(acc, x) { acc + x })
  @assertion.assert_eq(sum, 0)?
  queue.push(1)
  queue.push(2)
  queue.push(3)
  queue.push(4)
  let sum = queue.fold(~init=0, fn(acc, x) { acc + x })
  @assertion.assert_eq(sum, 10)?
  let sum2 = Queue::[1, 2, 3, 4].fold(~init=0, fn(acc, x) { acc + x })
  @assertion.assert_eq(sum2, 10)?
}
