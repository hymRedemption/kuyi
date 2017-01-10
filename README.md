# 问题分析
这个题目从现在看来，其主要的一个难点其实就是对时间的相关操作。
最核心的其实就是2个问题:
1. 两个日期之间整数月份数量是多少。
2. 两个日期之间是否是整数月份。


### 两个日期之间的整数月份
我计算的时候是以两个日期之间的月份只差为基础。

整数月份的数量与它们之间月份的差值存在3种关系：
1. 相等。例如: 1.3 ~ 2.4 之间的整数月是1，等于月份差值（2 - 1）
2. 大于1。这个情况就是日期分别在月初和月末的时候，例如 1.1 ~ 1.31。它们的整月数是1，但是月份差是0
3. 小于1。例如: 2.4 ~ 3.1 这种情况，它们之间的整月数是0，但是月份差是0

### 判断两个日期之间是否是整数月份
对于判断日期之间是否是整数月份的关系，可以通过下列方式

1. 检查两个日期是否分别为月初和月末。例如： 1.1 ~ 1.31 是一个整数月份
2. 如果上面条件不满足，然后日期又在同一个月，那么不是整数月份。 例如：1.1 ~ 1.21
3. 如果不在同一个月，那么判断日期大的月份里的天数，是否能够容纳下日期小的号。例如: 1.31 ~ 4.4, 4月份总共30天，不能够得到 31 号。
  + 如果不能容纳，那么判断大的日期是否在本月的月底，如果是，那么是整数月，如果不是，那么两个日期不是整数月。 例如 1.31 ~ 4.29 不是整数月。但是 1.31 ~ 4.30 是整数月。这个主要其实是解决 2 月这个特殊的情况
  + 如果能容纳，那么判断大日期的号数是否与小日期前一天的号数相同。例如 1.29 ~ 3. 12。 1.29 前一天的号数是28，不等于3.12 的 12,所以不是整数月，但是1.23 ~ 3.22 是一个整数月。

### 相关实现
与上面两个对应的方法：
integral_months_to: 计算整数月份
integral_months_to?: 判断两个日期是否是整数月份

还有一些依赖这个两个方法的一些衍生方法：
scattered_days_to: 计算两个日期之间不够整数月的零散天数

对于时间的相关的处理，都放在了 `lib/core_extensions/date_sugar` 中了，并作为一个 Date 类的猴子补丁

# 其他处理
### generate_contract 参数的约定
为了实现方便，代码默认约定所提供的 renting phases 的信息中除了第一个周期外，其他周期必须包含开始时间(start_date), 并且每个周期要提供周期相关信息(price, cycles)。也就是如下形式：
```ruby
{
  start_date: Date.new(1999, 1, 1),
  end_date: Date.new(1999, 12, 12),
  renting_phases: [
    {
      price: 100,
      cycles: 1
    },
    {
      start_date: Date.new(1999, 2, 4),
      price: 200,
      cycles: 2
    },
    {
      start_date: Date.new(1999, 4, 6),
      price: 150,
      cycles: 5
    }
  ]
}
```

对于所有的时间参数，不一定是 Date 的实例，可以是 Time、DateTime 或字符串，例如:
```ruby
{
  start_date: "1999-1-1",
  end_date: Time.new(1999, 12, 12),
  renting_phases: [
    {
      price: 100,
      cycles: 1
    },
    {
      start_date: DateTime.new(1999, 2, 4),
      price: 200,
      cycles: 2
    },
    {
      start_date: Time.new(1999, 3, 1, 1),
      price: 150,
      cycles: 5
    }
  ]
}
```

函数还会对时间做相关检查，对不符合逻辑的设置报错（例如 renting phase 超出了合同的日期）。相关检查处理等都由 `nomalize_param` 进行。
经过 `normalize_param` 处理后的参数会变成利于生成相关实例的形式。例如上面例子中会变成：
```ruby
{
  start_date: Date.new(1999, 1, 1),
  end_date: Date.new(1999, 12, 12),
  renting_phases: [
    {
      start_date: Date.new(1999, 1, 1),
      end_date: Date.new(1999, 2, 3),
      price: 100,
      cycles: 1
    },
    {
      start_date: Date.new(1999, 2, 4),
      end_date: Date.new(1999, 2, 28),
      price: 200,
      cycles: 2
    },
    {
      start_date: Date.new(1999, 3, 1, 1),
      end_date: Date.new(1999, 12, 12),
      price: 150,
      cycles: 5
    }
  ]
}
```

### 周期信息的生成
从 renting phase 产生 invoices 与从 invoice 产生 line_items，他们的逻辑很相似。如果将 line_items 看成是 invoice  以1个月为周期数而划分的周期的话。那么两者在本质上就可以统一起来了。都是生成所包含的相应周期的信息。

这个逻辑的实现放在了 DatePhase 这个模块中
