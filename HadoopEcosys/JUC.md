# JUC
## 一 JUC简介
**线程**每条执行路径都是一个线程
**进程**执行程序时，开启一个线程申请资源运行代码，有多条执行路径
**程序**一段可以执行的代码，静态
***多线程目的***①提高程序的运行效率②在核心功能不阻塞时，解决一些其他的无关的或耗时的操作

**守护线程**（后台线程）daemon，在后台运行的程序
**用户线程**（前台线程）用户正在使用的线程，切实和用户交互

Java 5.0提供了java.util.concurrent包，增加了在并发编程常用的工具类，用户定义类似于线程的自定义子系统，包括线程池、异步IO和轻量级任务框架，提供可调的、灵活的线程池，还提供了设计用于多线程上下文的Collection实现等。

## 二 多线程回顾
### 1.线程和进程
程序是静态的，程序运行后变为一个进程，一个进程内部可以有多个线程同时执行。进程是所有线程的集合，每一个线程是进程中的一条执行路径。
### 2.多线程的使用优势
①提高程序的响应，对图形化界面更有意义，可增强用户体验
②提高计算机CPU的利用率
③改善程序结构，将既长又复杂的进程分为多个线程，独立运行，利于理解和修改
④使用线程耗时任务放到后台去处理，例如等待用户输入、文件读写和网络收发数据等

### 3.多线程的创建方式
#### 3.1 继承Thread类
```java
class Thread1 extends Thread{//定义子类继承Thread类
	@Override
	public void run() {//重写run方法
		for (int i = 0; i < 100; i++) {
			if (i%2==0) {
				System.out.println(getName()+":------>"+i);
			}
		}		
	}
}

public class TheadDemo1 {
	public static void main(String[] args) 
		new Thread1().start();//创建Tread子类对象，使用start方法开启线程
		for (int i = 0; i < 100; i++) {
			if (i%2==1) {
				System.out.println("main:------>"+i);
			}
		}
	}
}
//如果只是调用run方法，此时会在调用该方法的线程执行，而不是另启动一个线程
```
#### 3.2 实现Runnable接口
```java
class Thread2 implements Runnable{//实现Runnable接口
	@Override
	public void run() {//重写run方法
		for (int i = 0; i < 100; i++) {
			if (i%2==0) {
				System.out.println(Thread.currentThread().getName()+":------>"+i);
			}
		}
	}	
}
public class TheadDemo1 {
	public static void main(String[] args) {
		new Thread(new Thread2()).start();//新建Runnable实现类的对象传入构造器创建Thread的对象，调用start方法开启线程
		for (int i = 0; i < 100; i++) {
			if (i%2==1) {
				System.out.println("main:------>"+i);
			}
		}
	}
}
//volatile修饰的属性，所有线程都可见(共享数据时)
```
继承方式和实现方式创建线程的区别
继承Thread：线程代码存放Thread子类的run方法中
实现Runnable：线程代码存放在接口实现类的run方法中
实现Runnable接口避免了单继承的局限性，多个线程可以共享同一个接口实现类的对象，非常适合多个相同线程来处理同一份资源

#### 3.3 使用匿名内部类创建线程
```java
public class TheadDemo1 {
	public static void main(String[] args) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				for (int i = 0; i < 100; i++) {	
					if (i%2==0) {
						System.out.println(Thread.currentThread().getName()+":------>"+i);
					}
				}
			}
		}).start();;
		for (int i = 0; i < 100; i++) {
			if (i%2==1) {
				System.out.println("main:------>"+i);
			}
		}
	}
}
//如果线程只需要创建一次，那么可以使用匿名内部类的方式创建
```
#### 3.4 使用Callable接口
Callable接口为JDK 1.5新增的接口
相比run方法，可以有返回值，方法可以抛出异常，支持泛型的返回值，需要借助FutureTask类，比如获取返回结果。Callable接口一般用于配合ExecutorService使用。
```java
/*
可以对具体Runnable、Callable任务的执行结果进行取消、查询是否完成、获取结果等。
FutrueTask是Futrue接口的实现类
FutureTask 同时实现了Runnable, Future接口。它既可以作为Runnable被线程执行，又可以作为Future得到Callable的返回值。
多个线程同时执行一个FutureTask，只要一个线程执行完毕，其他线程不会再执行其call()方法。
*/
class Thread06 implements Callable<Integer>{
	@Override
	public Integer call() throws Exception {
		int num=0;
		for (; num < 50; num++) {
			System.out.println(Thread.currentThread().getName()+"======》"+num);
		}
		return num;
	}
}
public class CallableThread {
	public static void main(String[] args) throws InterruptedException, ExecutionException {
		Thread06 thread06 = new Thread06();
		FutureTask<Integer> futureTask = new FutureTask<>(thread06);
		Thread thread = new Thread(futureTask);
		thread.start();
		Integer integer = futureTask.get();
		System.out.println(integer);
		System.out.println("主线程结束！");
	}
}
//get方法会阻塞当前线程
```
#### 3.5 使用线程池
经常创建和销毁、使用量特别大的资源，比如并发情况下的线程，对性能影响很大。因为提前创建多个线程，放入线程池中，使用时直接获取，使用完放回池中。可以避免频繁创建销毁、实现重复利用。
**优势**：
提高响应速度（减少了创建新线程的时间）
降低资源消耗（重复利用线程池中的线程，不需要每次都创建）
便于线程管理

**属性举例**：
**corePoolSize**：核心池的大小
**maximumPoolSize**：最大线程数
**keepAliveTime**：线程没有任务时最多保持多长时间会终止。

**ExecutorService接口**
常见子类ThreadPoolExecutor
`void execute(Runnable command)`执行任务/命令，没有返回值
`<T>Future <T> submit(Callable<T> task)`执行任务，有返回值，一般用来执行Callable
`void shutdown()`关闭连接池
**Executors工具类**
用于创建并返回不同类型的线程池
`Executors.newCachedThreadPool()`创建一个可根据需要创建新线程的线程池
`Executors.newFixedThreadPool(n)`创建一个可重用固定线程数的线程池
`Executors.newSingleThreadExecutor()`创建一个只有一个线程的线程池
`Executors.newScheduledThreadPool(n)`创建一个线程池，它可安排在给定延迟后运行命令或者定期地执行。

```java
public static void main(String[] args) throws InterruptedException, ExecutionException {
		ExecutorService executorService = Executors.newFixedThreadPool(10);
		executorService.submit(new Thread06());		
		executorService.shutdown();
}
```

### 4.线程的常用方法
**Thread中常用api方法** | |
-|-
start()  | 启动线程；    
currentThread()  | 获取当前线程对象 
getID() | 获取当前线程ID 
getName() | 获取当前线程名称，Thread-编号    该编号从0开始
setName() | 设置当前线程的名字  
sleep(long   mill) | 休眠线程
stop() | 停止线程
yield()| 释放cpu的操作
join() | 加塞，谁调join()，谁先执行，当前线程被阻塞，直到   join() 方法加入的 join 线程执行完为止。
isAlive() | 判断线程是否还活着 
**常用线程构造函数** |  |
Thread() | 创建一个新的   Thread 对象  
Thread(String name)| 创建一个新的   Thread对象，具有指定的 name正如其名。 
Thread(Runnable r)| 创建一个新的   Thread对象 
Thread(Runable r, String name) | 创建一个新的Thread对象

**注意**如果同一线程对象，执行两次start方法，会报错`java.lang.IllegalThreadStateException`

### 5.线程控制
基于**时间片**的调度策略,同优先级线程组成先进先出队列（先到先服务）
**抢占式**的调度策略,高优先级的线程会抢占CPU

### 6.线程的优先级
**优先级**
MAX_PRIORITY（10）   
MIN _PRIORITY （1） 
NORM_PRIORITY （5）

**常用方法**
getPriority() ：返回线程优先级
setPriority(int newPriority) ：设置线程的优先级

*子线程创建时继承父线程的优先级*

### 7.线程的声明周期
**新建**： 当一个Thread类或其子类的对象被声明并创建时。
**就绪**： 处于新建状态的线程被start()后，将进入线程队列等待CPU时间片，此时它已具备了运行的条件。
**运行**： 当就绪的线程被调度并获得处理器资源时,便进入运行状态，run()方法定义了线程的操作和功能。
**阻塞**：在某种特殊情况下，被人为挂起或执行输入输出操作时，让出 CPU 并临时中止自己的执行，进入阻塞状态。
**死亡**：线程完成了它的全部工作或线程被提前强制性地中止 。

### 8.线程的状态
线程状态|描述
:-:|-
NEW|未开启
RUNNABLE|JVM中正在执行的线程
BLOCKED|等待线程监视器交锁
WAITING|无限期等待别的线程进行操作
TIMED_WAITING| 等待一个有明确时间限制的等待
TEAMINATED| 线程已退出
### 9.线程的分类
**守护线程**（后台线程）daemon，在后台运行的程序
**用户线程**（前台线程）用户正在使用的线程，切实和用户交互
唯一的区别是判断JVM何时离开。

守护线程是用来服务用户线程的，通过在start()方法前调用thread.setDaemon(true)可以把一个用户线程变成一个守护线程。当主线程不存在或主线程停止时，守护线程也会停止。
**Java垃圾回收**就是一个典型的守护线程。若JVM中都是守护线程，当前JVM将退出。

### 10.线程的停止
使用**退出标志**，使线程**正常退出**，也就是当run方法完成后线程终止。
使用**stop**方法**强行终止**线程（已过时）。
使用**interrupt**方法**中断**线程。


## 三、线程的安全问题
### 1.线程安全
#### 1.1什么是线程安全
多个线程同时共享同一个全局变量或静态变量，做写操作时，可能会发生数据冲突问题，也就是线程安全问题，单纯的读操作不会发生数据冲突问题。

#### 1.2线程安全的解决方式
多线程之间同步或使用锁来解决线程安全问题
#### 1.3什么是多线程的同步
多线程共享同一资源的环境下，每个线程工作时不会受到其他线程的干扰成为**线程同步**
### 2.解决线程安全
#### 2.1使用同步代码块
```java
synchronized(Object.class){//锁时同一个对象
 	//可能发生线程冲突的代码块
}
/*
在同步代码块中，多个线程必须使用的是同一把锁，即同一个对象。
一般情况下，在使用Runnable实现的线程类中，我们会使用this作为锁对象。
*/
```
#### 2.2使用同步方法
```java
private synchronized boolean sell() 
			if (tickets > 0) {
				System.out.println(Thread.currentThread().getName()+"售出："+tickets+"  号车票！");
				tickets--;
				return true;
			}else {
				return false;
			}
		
}
//如果使用Thread继承的方式实现多线程，那么同步方法需要一个静态的方法！
```
#### 2.3常见问题
①静态同步函数，函数使用的锁是该函数所属字节码文件对象
②同步代码块使用自定义锁（明锁），同步函数使用this锁
③死锁指不同的线程分别占用对方需要的同步资源不放弃，都在等待对方放弃自己需要的同步资源，就形成了线程的死锁。出现死锁后，不会出现异常，不会出现提示，只是所有的线程都处于阻塞状态，无法继续。死锁一般在同步代码块中嵌套同步代码块时出现。
```java
public class DeadLock {
	private static StringBuffer s1=new StringBuffer();
	private static StringBuffer s2=new StringBuffer();
	public static void main(String[] args) {
		new Thread(new Runnable() {	
			@Override
			public void run() {	
				synchronized (s1) {	
					s1.append("a");
					s2.append(1);
					try {
						Thread.sleep(100);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					synchronized (s2) {
						s1.append("b");
						s2.append(2);
						System.out.println(s1);
						System.out.println(s2);
					}
				}
			}
		}).start();
		
		new Thread(new Runnable() {
			@Override
			public void run() {
				
				synchronized (s2) {	
					s1.append("c");
					s2.append(3);
					try {
						Thread.sleep(100);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					synchronized (s1) {
						s1.append("d");
						s2.append(4);
						System.out.println(s1);
						System.out.println(s2);
					}
				}
			}
		}).start();
	}
}
//在多线程编程中，尽量避免同步代码块的嵌套，避免使用同样的锁来避免死锁。
```
#### 2.4同步锁的作用域

#### 2.5使用Lock解决线程安全
JDK1.5之后，通过显式定义同步锁对象来实现同步
同步锁使用Lock对象充当
`java.util.concurrent.locks.Lock`接口是控制多个线程对共享资源进行访问的工具
锁提供了对共享资源的独占，每次只能有一个线程对Lock对象加锁，线程开始访问共享资源前应先获得Lock对象
ReentrantLock类实现了Lock，拥有与synchronized相同的并发性和内存语义，在实现线程安全的控制中，比较常用的时ReentrantLock，可以显示加锁，释放锁。
```java
class Thread1 implements Runnable{
	private ReentrantLock lock =new ReentrantLock(true);
	@Override
	public void run() {
			try {
				lock.lock();
				//操作资源
			} finally {
				lock.unlock();
			}
		}
}
//相比synchronized是由系统自动获取锁和释放锁，Lock需要自己手动实现加锁和释放锁，更加灵活！
```
## 四、线程的通信

### 1.什么是线程通信


### 2.常用的线程通信方法


### 3.使用Lock后线程通信
**Condition**的功能类似于在传统的线程技术中的Object.wait()和Object.notify()
`Condition.await()`
`Condition.singal()`

```java
class Thread01 implements Runnable{
	private int num = 1;
	private ReentrantLock lock=new ReentrantLock(true);
	private Condition condition=lock.newCondition();
	@Override
	public void run() {
		while(true){
			try {
				lock.lock();
				condition.signal();
				if (num <= 100) {
					System.out.println(Thread.currentThread().getName()+"---->"+num);
					num++;
					try {
						condition.await();
					} catch (InterruptedException e1) {
						e1.printStackTrace();
					}
				}else {
					break;
				}
			} finally {
				lock.unlock();
			}
		}
	}
}
```
```java
//三线程通信
package com.tian.juc;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class ConditionDemo {
	public static void main(String[] args) {
		Restuarant restuarant = new Restuarant();
		new Thread(new Runnable() {

			@Override
			public void run() {
				for (int i = 0; i < 10; i++) {
					restuarant.cut();
				}
			}
		}, "cuttor:zhang").start();
		new Thread(new Runnable() {

			@Override
			public void run() {
				for (int i = 0; i < 10; i++) {
					restuarant.cook();
				}
			}
		}, "cookor:wang").start();
		new Thread(new Runnable() {

			@Override
			public void run() {
				for (int i = 0; i < 10; i++) {
					restuarant.pass();
				}
			}
		}, "passor:li").start();
	}
}

class Restuarant {
	private int status = 0;
	private ReentrantLock lock = new ReentrantLock(true);
	private Condition cutCondition = lock.newCondition();
	private Condition cookCondition = lock.newCondition();
	private Condition passCondition = lock.newCondition();

	public void cut() {
		lock.lock();
		try {
			while (status != 0) {
				try {
					cutCondition.await();
				} catch (Exception e) {
					e.getStackTrace();
				}
			}
			try {
				Thread.sleep(1000);

			} catch (Exception e) {
				e.getStackTrace();
			}
			System.out.println(Thread.currentThread().getName() + " cut finished!");
			status = 1;
			cookCondition.signal();
		} finally {
			lock.unlock();
		}
	}

	public void cook() {
		lock.lock();
		try {
			while (status != 1) {
				try {
					cookCondition.await();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			System.out.println(Thread.currentThread().getName() + " cook finished!");
			status = 2;
			passCondition.signal();
		} finally {
			lock.unlock();
		}
	}

	public void pass() {
		lock.lock();
		try {
			while (status != 2) {
				try {
					passCondition.await();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			System.out.println(Thread.currentThread().getName() + " pass finished!");
			status = 0;
			cutCondition.signal();
		} finally {
			lock.unlock();
		}
	}
}
```
## 五、JUC工具类

### 1.ReentrantReadWriteLock
对共享资源有读和写的操作，且写操作没有读操作那么频繁。
**共享锁**读相关锁
**排他锁**写相关锁
当没有其他线程的写锁时，线程进入读锁。当没有其他线程的读锁和写锁时，才会进入当前线程的写锁!
```java
/*
有问题，待商榷
*/
package com.tian.juc;

import java.util.concurrent.locks.ReentrantReadWriteLock;

public class ReentrantReadWriteLockDemo {
	public static void main(String[] args) {
		/*
			viewer 1 watching movie None
			viewer 1 leave 
			worker 1 changing movie
			viewer 2 watching movie GodFather
			viewer 2 leave 
			worker 2 changing movie
		 */
		Cinema cinema = new Cinema();
		new Thread(new Runnable() {
			@Override
			public void run() {
				cinema.watch();
			}
		},"viewer 1").start();
		new Thread(new Runnable() {
			@Override
			public void run() {
				cinema.work("GodFather");
			}
		},"worker 1").start();
		new Thread(new Runnable() {
			@Override
			public void run() {
				cinema.watch();
			}
		},"viewer 2").start();
		new Thread(new Runnable() {
			@Override
			public void run() {
				cinema.work("Titanic");
			}
		},"worker 2").start();
	}
}

class Cinema {
	private Object film = "None";

	private ReentrantReadWriteLock lock = new ReentrantReadWriteLock();

	public void work(Object film) {
		lock.writeLock().lock();
		try {
			Thread.sleep(3000);
			this.film = film;
			System.out.println(Thread.currentThread().getName() + " changing movie");
		} catch (InterruptedException e) {
			e.printStackTrace();
		} finally {
			lock.writeLock().unlock();
		}
	}

	public void watch() {
		lock.readLock().lock();
		System.out.println(Thread.currentThread().getName() + " watching movie " + film);
		try {
			Thread.sleep(1000);

		} catch (InterruptedException e) {
			e.printStackTrace();
		} finally {
			System.out.println(Thread.currentThread().getName() + " leave ");
			lock.readLock().unlock();
		}
	}
}
```
### 2.CountDownLatch
线程调用await()方法时阻塞，其他线程调用countDown方法使计数器减1，当计数器数值变为0时被阻塞的线程会被唤醒。
```java
package com.tian.juc;

import java.util.concurrent.CountDownLatch;

public class CountDownLatchDemo {
	public static void main(String[] args) {
		CountDownLatch countDownLatch = new CountDownLatch(10);
		System.out.println("monitor is locking the door!");
		for (int i = 1; i <= 10; i++) {
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					try {
						Thread.sleep(2000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName() + "-- leaving room");
					countDownLatch.countDown();
				}
			},"student-" + i).start();
			
		}
		try {
			countDownLatch.await();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		System.out.println("monitor locked the door");
	}
}

```
### 3.CyclicBarrier
CyclicBarrier的字面意思是可循环（Cyclic）使用的屏障（Barrier）。它要做的事情是，让一组线程到达一个屏障（也可以叫同步点）时被阻塞，直到最后一个线程到达屏障时，屏障才会开门，所有被屏障拦截的线程才会继续干活。线程进入屏障通过CyclicBarrier的await()方法。
```java
package com.tian.juc;

import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;

public class CyclicBarrierDemo {
	public static void main(String[] args) {
		CyclicBarrier cyclicBarrier = new CyclicBarrier(5, new Runnable() {
			
			@Override
			public void run() {
				System.out.println("headmaster say");
			}
		});
		for (int i = 1; i <= 5; i++) {
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName() + "together done,waitting!");
					try {
						cyclicBarrier.await();
					} catch (InterruptedException e) {
						e.printStackTrace();
					} catch (BrokenBarrierException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName() + "-dismiss");
				}
			},i + "-class").start();
		}
	}
}

```
### 4.Semaphore
**acquire**（获取） 当一个线程调用acquire操作时，它要么通过成功获取信号量（信号量减1），要么一直等下去，直到有线程释放信号量，或超时。
**release**（释放）实际上会将信号量的值加1，然后唤醒等待的线程。 
信号量主要用于两个目的，一个是用于多个共享资源的互斥使用，另一个用于并发线程数的控制。
```java
package com.tian.juc;

import java.util.concurrent.Semaphore;

public class SemaphoreDemo {
	public static void main(String[] args) {
		Semaphore semaphore = new Semaphore(5, true);
		for (int i = 1; i <= 10; i++) {
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					try {
						semaphore.acquire();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName() + "-eatting...");
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName() + "-eat done!");
					semaphore.release();
				}
			},i + "-customer").start();
		}
	}
}	

```

### 5.锁的总结
分类方法|分类
:-:|:-:
特质|共享锁和排他锁
用途|读锁和写锁
数据库|表锁和行锁
世界观|悲观锁（真锁）和乐观锁（假锁）
显隐|显式锁和隐式锁