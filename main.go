package main

import (
	"fmt"
	"sync"
	"sync/atomic"
)

// func addTen(num *int){
//     *num+=10
// }

// func prJNum(wg*sync.WaitGroup){
//     defer wg.Done()//完成时通知
//     for i := 1; i < 10; i+=2{
//         fmt.Println(i)
//     }
// }

// func prONum(wg*sync.WaitGroup){
//     defer wg.Done()//完成时通知
//     for i := 0; i < 10; i+=2{
//         fmt.Println(i)
//     }
// }

// type Shape interface {
// 	Area() float64
// 	Perimeter() float64
// }

// type Rectangle struct {
// 	width  float64
// 	Height float64
// }

// func (r Rectangle) Area() float64 {
// 	return r.width * r.Height
// }

// func (r Rectangle) Perimeter() float64 {
// 	return 2 * (r.width + r.Height)
// }

// type Circle struct {
// 	Radius float64
// }

// func (c Circle) Area() float64 {
// 	return math.Pi * c.Radius * c.Radius
// }

// func (c Circle) Perimeter() float64 {
// 	return 2 * math.Pi * c.Radius
// }

// type Person struct {
// 	Name string
// 	Age  int
// }

// // 组合Person结构体
// type Employee struct {
// 	Person
// 	EmployeeID string
// }

// func (e Employee) PrintInfo() {
// 	fmt.Printf("Employee Info:\n")
// 	fmt.Printf("Name: %s\n", e.Name)
// 	fmt.Printf("Age: %d\n", e.Age)
// 	fmt.Printf("EmployeeID: %s\n", e.EmployeeID)
// }

// // 生产者
// func prodducer(ch chan int) {
// 	for i := 1; i < 10; i++ {
// 		ch <- i //发送数据到通道
// 	}
// 	close(ch) //发送完毕关闭通道
// }

// func prodducer2(ch chan int) {
// 	for i := 1; i < 100; i++ {
// 		ch <- i //发送数据到通道
// 	}
// 	close(ch) //发送完毕关闭通道
// }

// // 消费者
// func consumer(ch chan int) {
// 	for num := range ch {
// 		fmt.Println("Received:", num)
// 	}
// }

func main() {
	// n:=5
	// fmt.Println("原值：",n)
	// addTen(&n)
	// fmt.Println(n)

	// var wg sync.WaitGroup

	// wg.Add(1)
	// go prJNum(&wg)

	// wg.Add(1)
	// go prONum(&wg)

	// wg.Wait()

	// var s Shape

	// s =Rectangle{width: 5,Height: 3}
	// fmt.Println("Rectangle Area:",s.Area())
	// fmt.Println("Re  Per:",s.Perimeter())

	// s=Circle{Radius: 4}
	// fmt.Println("Circle Area:",s.Area())
	// fmt.Println("Circle Per:",s.Perimeter())

	// //面向对象2
	// //创建Employee的实例
	// emp := Employee{
	// 	Person: Person{
	// 		Name: "Alice",
	// 		Age:  27,
	// 	},
	// 	EmployeeID: "E01",
	// }
	// emp.PrintInfo()

	//Channel
	//题目 ：编写一个程序，使用通道实现两个协程之间的通信。一个协程生成从1到10的整数，并将这些整数发送到通道中，
	// 另一个协程从通道中接收这些整数并打印出来。考察点 ：通道的基本使用、协程间通信。
	// ch := make(chan int) // 创建一个整型通道
	// go prodducer(ch)

	// consumer(ch)

	//题目 ：实现一个带有缓冲的通道，生产者协程向通道中发送100个整数，消费者协程从通道中接收这些整数并打印。
	// 考察点 ：通道的缓冲机制

	// ch := make(chan int, 10)    //创建一个带缓冲的通道
	// go prodducer2(ch)
	// consumer(ch)

	// 生产者最多可以在没有消费者立即读取的情况下，往里放 10 个数据。
	// 超过容量后，生产者会阻塞，直到消费者取出一些数据。
	// close(ch)：关闭通道，让消费者知道数据已经发完。
	// for num := range ch：一种优雅的写法，自动读取直到通道关闭。

	//锁机制
	//题目 ：编写一个程序，使用 sync.Mutex 来保护一个共享的计数器。启动10个协程，每个协程对计数器进行1000次递增操作，最后输出计数器的值。

	// var counter int  //共享计时器
	// var mu sync.Mutex   //互斥锁
	// var wg sync.WaitGroup   //用于等待所有的goroutine 完成

	// numGoroutines:=10   //启动10个协程
	// increments:=1000        //每个协程递增1000次
	// wg.Add(numGoroutines)
	// for i := 0; i < numGoroutines; i++ {
	//     go func() {
	//         defer wg.Done()
	//         for j := 0; j < increments; j++{
	//             mu.Lock()  //加锁
	//             counter++   //修改共享变量
	//             mu.Unlock()     //解锁
	//         }
	//     }()
	// }
	// wg.Wait()       //等待所有协程完成
	// fmt.Println("Final Counter:",counter)
	//互斥锁（Mutex） 保证同一时刻只有一个 goroutine 能进入临界区。
	// 如果不用 mu.Lock()/mu.Unlock()，多个 goroutine 会并发写 counter，导致 数据竞争（data race）。
	// 使用 sync.WaitGroup 等待所有协程完成，否则 main() 可能提前退出。

	//题目 ：使用原子操作（ sync/atomic 包）实现一个无锁的计数器。启动10个协程，每个协程对计数器进行1000次递增操作，
	// 最后输出计数器的值。考察点 ：原子操作、并发数据安全。
	var counter int64
	var wg sync.WaitGroup
	numGoroutines := 10
	increments := 1000
	wg.Add(numGoroutines)
	for i := 0; i < numGoroutines; i++ {
		go func() {
			defer wg.Done()
			for j := 0; j < increments; j++ {
				atomic.AddInt64(&counter, 1) //原子递增
			}
		}()
	}
	wg.Wait()
	fmt.Println("final,counter", counter)

	//sync.Mutex：需要显式 Lock() 和 Unlock()，开销稍大，但功能更强（能保护复杂临界区）
	//sync/atomic：只适用于一些基本数值操作（加减、读写、CAS 等），优势是 无锁 + 高性能。
}
