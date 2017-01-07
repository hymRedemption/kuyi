# 完成情况
+ 由于对于相关 date 的约束没有理出一个比较好的思路，并没通过得了所有测试，与 date 相关的代码也比较混乱
+ 还没有对相关方法做优化，现在每次调用方法都会产生新的数据，会造成垃圾数据越来越多
+ 相关接口调用目前也并是那么好用，比如目前对于日期需要提供 Date 实例，而无法使用字符串

# 调用例子
```ruby```
   params = {
      start_date: Date.new(1999, 1,1),
      end_date: Date,new(1999, 12, 12)
      renting_phases: [
        {
          end_date: Date.new(1999, 2, 3),
          price: 199,
          cycles: 1
        },
        {
          end_date: Date.new(1999, 4, 5),
          cycles: 2,
          price: 2,
        },
        {
          end_date: Date.new(1999, 12, 12),
          price:2,
          cycles: 1
        }
      ]
   }
   Controct.generate_contract(params)
```ruby```
