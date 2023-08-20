# CRM

# 项目介绍

CRM客户关系管理是管理企业与客户之间关系的新型管理机制

终极目标是吸引新客户、保留老客户以及将已有客户转变为忠诚客户，以增加市场份额

它是一个完整的客户关系管理系统，包括市场、销售、服务3大环节

产品成熟，操作简单，功能强大，帮您从客户全生命周期的各个阶段获取价值



这是一类软件，很多公司专门做这种CRM系统

我们这个系统，是从咱们一个非常有名的专门致力于CRM项目开发的公司中拿过来的

不同行业的CRM，功能一点都不一样，它是由销售模式来决定的，你比如有分销和直销



CRM为改善企业与客户之间关系的提供了一种新型管理机制企业

可以规划市场营销活动、增加销售线索、规范客户联系人信息、对不同阶段的交易进行有效区分和统计

妥善安排售后回访、为决策提供支撑等，优化各业务环节，减少各环节客户流失，和公司成本

当然，我们不是全部都做，我们只是拿出来其中的某几个模块来做



业务流程：

市场活动：市场部人员

线索：销售部人员(线索购买意愿非常强烈的时候，可以转换)

客户：线索中的公司信息

联系人：线索中的联系人信息

交易：已经促成的交易，促成的交易不一定就肯定成交，只有那些已经有交易意向的客户才创建交易记录

交易中有一些阶段，总共九个阶段，越是往下越是成交的可能性越大，当然也可能最后成交失败

售后回访：客服人员，成交之后的

统计报表：销售漏斗，主要体现交易数据各个阶段的数据变化

# 项目配置

## 1:Spring配置文件

1、引入JDBC配置，配置阿里巴巴德鲁伊数据库连接池

2、包扫描器

3、配置Mybatis的SqlSessionFactoryBean

4、配置项目允许使用切面

## 2:SpringMVC配置

1、开启注解配置

2、组件扫描

3、视图解析器

4、拦截器

5、文件上传解析的配置

## 3:webxml配置

1、字符编码过滤器的配置

2、配置 DispatcherServlet，也就是加载 SpringMVC 的配置文件

3、监听器加载 Spring 的配置文件，注册Spring框架

4、配置欢迎页为 " / "

# 登录和首页功能

1、专门定义一个控制器，路径为 " / "

2、接收到请求直接 return index【则为视图解析器位置下的 index】

3、这个页面跳转到 toLogin 的路径

4、被路径为 toLogin 的控制器接收，跳转到登录页面，登陆成功把数据写入 Session，返回结果

5、解析结果，成功的话就把路径变为工作台的首页 workbench/toIndex

6、被拦截器拦截，验证是不是存在 Session，存在则放行，否则返回登录页

7：被路径为 workbench/toIndex 的控制器接收，跳转到工作台的首页



登陆的时候的怎么显示的："正在努力验证中...."

Ajax 发请求之前有一个函数叫做：beforeSend，我们就在这里把对应的元素拿到，使用 text() 赋值即可

# 记住密码的实现

就是创建两个 Cookie

然后值分别为 账号 和 密码

然后把我们的 Cookie 写入我们的浏览器即可

直接通过 responseaddCookie 把两个 Cookie 写给客户端

如果用户没有勾选这个选项，我们则直接把这个 Cookie 的有效期设置为 0

直接调用 Cookie 对象的 setMaxAge，设置为 0 即可

我们存入密码到 Cookie 的时候，存储的是加密的密码，不可逆

并且为了掩人耳目，还可以把这个 key 不写的那么见名知意，这样就不容易发觉了



对于前端而言：直接使用Jquery的 **${cookiecookie的键value}** 就可以获取了

这样我们只要存在了Cookie，则就会直接把账号密码显示在这里



加密算法是自己找的，得到的密文和原始密码的长度相同



后台处理的时候：

1、如果记住密码的标识是假，则直接在后台加密，处理登录验证的请求

2、如果记住密码的标识是真，浏览器也不存在登录的 Cookie

则直接在后台加密，处理登录验证的请求，并且写入加密的密码和账号信息到我们浏览器的 Cookie 里面

2、如果记住密码的标识是真，浏览器也存在登录的 Cookie

则直接在绕过加密，直接按照传递的密码参数来处理登录验证的请求

并且写入加密的密码和账号信息到我们浏览器的 Cookie 里面

# 安全退出的实现

1、设置我们的账号密码的 Cookie 有效期设置为 0，直接调用 Cookie 对象的 setMaxAge，设置为 0 即可

2、销毁我们的 Session 对象，使用 session 对象的 invalidate() 方法来让这个会话无效

本质就是把我们的浏览器本地的 JSESSIONID 干掉，让其下次来的时候是一个新的会话

# 修改密码

1、这个没什么说的，主要是修改密码之后记得清除Cookie的信息，并且删除会话的信息并跳转到登录页

# 数据字典

## 1:数据字典类型维护

<img src=".\assets\image-20230507161435927.png" alt="image-20230507161435927" style="zoom:150%;" />

## 2:数据字典值维护

<img src=".\assets\image-20230507161502232.png" alt="image-20230507161502232" style="zoom:150%;" />

## 3:关系

数据字典的值主要里面有一个数据字典的类型字段，表明自己是哪一类数据

```sql
# 查询所有称呼的字典值
select id，value from tbl_dic_value where type_code = 'appellation'

# 查询所有线索状态的字典值
select id，value from tbl_dic_value where type_code = 'clueState'
```

查询所有称呼的字典值

<img src=".\assets\image-20230507161516782.png" alt="image-20230507161516782" style="zoom:200%;" />



查询所有线索状态的字典值

<img src=".\assets\image-20230507161653692.png" alt="image-20230507161653692" style="zoom:150%;" />



主要就是根据这个类型，来获取这个类型下面有哪些可选项，然后展现在下拉框下面给我们选择

# 市场活动

## 1:分页请求

参数：搜索框的参数，当前页，页的大小，封装为map，进行查询

查询成功之后把数据存入我们需要返回的JSON对象里面，包括市场活动信息 + 总记录数

成功了则拿到市场活动信息，手动拼接我们需要的 HTML 字符串

拿到 tbody 的标签，直接使用 jquery 的 html 把字符串赋值给他

然后手动计算共有多少页，又整合给分页插件，使用的是 jquery 的 pagination 分页组件

除了基本信息，还有复选框和单选框的事件，这些都需要手动处理，添加事件

```js
// TODO 给全选的checked框按钮绑定相对应的事件
$("#allCheckRemark")click(function () {
    $("#activityBodyForPage input[type='checkbox']")prop("checked"， thischecked)
})

// TODO 给动态生成的checked框绑定单击事件
$("#activityBodyForPage")on("click"， "input[type='checkbox']"， function () {
    if ($("#activityBodyForPage input[type='checkbox']")size()
        == $("#activityBodyForPage input[type='checkbox']:checked")size()) {
        $("#allCheckRemark")prop("checked"， true)
    } else {
        $("#allCheckRemark")prop("checked"， false)
    }
})
```

联表查询的思路：只涉及到一个所有者的信息，也就是用户的信息，则只联表查询这个即可

![image-20230507171052100](.\assets\image-20230507171052100.png)

## 2:创建市场活动

需求：

用户在市场活动主页面，点击"创建"按钮，弹出创建市场活动的模态窗口

用户在创建市场活动的模态窗口填写表单，点击"保存"按钮，完成创建市场活动的功能

所有者是动态的(在市场活动主页面时，就从数据库中查询出所有用户并且显示在创建的模态窗口中)

所有者和名称不能为空，成本只能为非负整数

如果开始日期和结束日期都不为空，则结束日期不能比开始日期小

创建成功之后，关闭模态窗口，刷新市场活动列，显示第一页数据，保持每页显示条数不变

创建失败，提示信息创建失败，模态窗口不关闭，市场活动列表也不刷新





点击创建活动，弹出模态窗口，填写数据，拿到数据，数据格式校验，发送 Ajax 请求

服务器先进行数据的填充，创建时间，创建人，生成市场活动ID等，返回Json响应

失败了：提示信息，不关闭模态窗口

成功了：关闭模态窗口，重新发送分页请求，渲染数据到页面



## 3:查询市场活动

当市场活动主页面加载完成之后，直接显示所有数据的第一页

用户在市场活动主页面填写查询条件，点击"查询"按钮，显示所有符合条件的数据的第一页

保持每页显示条数不变

实现翻页功能：使用的是 jquery 的 pagination 分页组件，翻页触发事件

在市场活动主页面，显示市场活动列表和记录的总条数

默认每页显示条数:10

使用的都是同一个接口，主要就是查询市场活动信息和符合查询条件的总记录数

也就是上面的分页请求



## 4:修改市场活动

用户在市场活动主页面，选择要修改的市场活动，点击"修改"按钮，弹出修改市场活动的模态窗口

用户在修改市场活动的模态窗口填写表单，点击"更新"按钮，完成修改市场活动的功能

每次能且只能修改一条市场活动

所有者 动态的

表单验证(同创建)

修改成功之后，关闭模态窗口，刷新市场活动列表，保持页号和每页显示条数都不变

修改失败，提示信息，模态窗口不关闭，列表也不刷新



先拿到我们需要操作的数据的  ID

![image-20230507172336558](.\assets\image-20230507172336558.png)

查询数据成功之后返回 Json 数据，然后把模态窗口内的数据进行依次赋值，然后展开修改的模态窗口

<img src=".\assets\image-20230507172610529.png" alt="image-20230507172610529" style="zoom:150%;" />

填写数据，点击更新之后进行数据校验，执行更新操作，更新成功返回市场活动列表

## 5:删除市场活动

用户在市场活动主页面，选择要删除的市场活动，点击"删除"按钮，弹出确认窗口

用户点击"确定"按钮，完成删除市场活动的功能

每次至少删除一条市场活动

可以批量删除市场活动

删除成功之后，刷新市场活动列表，显示第一页数据，保持每页显示条数不变

删除失败，提示信息，列表不刷新



先使用这个来拿到我们所选择的市场活动，在前面分页查询显示数据的时候已经拼接了对应的ID

然后我们动态拼接我们的ID，中间使用 & 连接，在后台可以直接被字符串数组接收

![image-20230507171502225](.\assets\image-20230507171502225.png)

后台使用SQL，直接处理即可

![image-20230507172015408](.\assets\image-20230507172015408.png)

## 6:批量导出市场活动

用户在市场活动主页面，点击"批量导出"按钮，把所有市场活动生成一个excel文件，弹出文件下载的对话框

用户选择要保存的目录，完成导出市场活动的功能

导出成功之后，页面不刷新



点击按钮触发事件，用户点击确定之后发送请求

<img src=".\assets\image-20230507214702591.png" alt="image-20230507214702591" style="zoom:150%;" />

选择全部下载就是不携带任何的请求市场活动的ID参数，但是后台接口是有 String[] id 的形式参数的

主要就是接收到ID的数组参数，当然也可以没有参数去查询市场活动的信息，没有就是查询全部了

![image-20230507215841490](.\assets\image-20230507215841490.png)

查询到这些数据之后，就需要进行封装为Excel数据的操作了

```java
//创建Excel的对象
HSSFWorkbook workbook = new HSSFWorkbook();
HSSFSheet sheet = workbook.createSheet("市场活动明细列表");
HSSFRow row = sheet.createRow(0);

//创建表头
HSSFCell cell = null;
cell = row.createCell(0);
cell.setCellValue("所有者");
cell = row.createCell(1);
cell.setCellValue("名称");
cell = row.createCell(2);
cell.setCellValue("开始时间");
cell = row.createCell(3);
cell.setCellValue("结束时间");
cell = row.createCell(4);
cell.setCellValue("花费");
cell = row.createCell(5);
cell.setCellValue("描述");
cell = row.createCell(6);
cell.setCellValue("创建时间");
cell = row.createCell(7);
cell.setCellValue("创建人");
cell = row.createCell(8);
cell.setCellValue("修改时间");
cell = row.createCell(9);
cell.setCellValue("修改人");

//拿到每个市场活动，写入Excel的数据里面
for (int i = 0; i < activities.size(); i++) {
    row = sheet.createRow(i + 1);
    Activity activity = activities.get(i);
    //内容
    cell = row.createCell(0);
    cell.setCellValue(activity.getOwner());
    cell = row.createCell(1);
    cell.setCellValue(activity.getName());
    cell = row.createCell(2);
    cell.setCellValue(activity.getStartDate());
    cell = row.createCell(3);
    cell.setCellValue(activity.getEndDate());
    cell = row.createCell(4);
    cell.setCellValue(activity.getCost());
    cell = row.createCell(5);
    cell.setCellValue(activity.getDescription());
    cell = row.createCell(6);
    cell.setCellValue(activity.getCreateTime());
    cell = row.createCell(7);
    cell.setCellValue(activity.getCreateBy());
    cell = row.createCell(8);
    cell.setCellValue(activity.getEditTime());
    cell = row.createCell(9);
    cell.setCellValue(activity.getEditBy());
}

//返回流数据给前端即可
response.setContentType("application/octet-stream;charset=UTF-8");
response.addHeader("Content-Disposition", "attachment;filename=activityList.xls");
OutputStream os = response.getOutputStream();
workbook.write(os);
workbook.close();
```



## 7:选择导出市场活动

用户在市场活动主页面，选择要导出的市场活动，点击"选择导出"按钮

把所有选择的数据生成一个excel文件，弹出文件下载的对话框

用户选择要保存的目录，完成选择导出市场活动的功能

每次至少选择导出一条记录

导出成功之后，页面不刷新



这个跟全部下载没有什么区别，主要就是这个携带了市场活动的ID，这样查询市场活动的时候数据不一样了

![image-20230507220247656](.\assets\image-20230507220247656.png)

## 8:模板文件下载

其实就是创建一个 Excel 的对象，写入数据，使用流返回即可

```java
//设置返回数据的格式信息和流的准备
response.setContentType("application/octet-stream;charset=UTF-8");
response.addHeader("ConTent-Disposition", "attachment;filename=activityList.xls");
OutputStream os = response.getOutputStream();

//Excel的数据准备
HSSFWorkbook workbook = new HSSFWorkbook();
HSSFSheet sheet = workbook.createSheet("市场活动模板");

//创建第0行，也就是表头的信息
HSSFRow row = sheet.createRow(0);
//为第0行的各列赋值
HSSFCell cell = null;
cell = row.createCell(0);
cell.setCellValue("市场活动名称");
cell = row.createCell(1);
cell.setCellValue("市场活动开始时间");
cell = row.createCell(2);
cell.setCellValue("市场活动结束时间");
cell = row.createCell(3);
cell.setCellValue("花费");
cell = row.createCell(4);
cell.setCellValue("描述");


//第1行，也就是第一行模板数据的信息
row = sheet.createRow(1);
//为第1行的各列赋值
cell = row.createCell(0);
cell.setCellValue("内江师范学院三食堂建设");
cell = row.createCell(1);
cell.setCellValue("2021-01-31");
cell = row.createCell(2);
cell.setCellValue("2022-01-31");
cell = row.createCell(3);
cell.setCellValue("500000");
cell = row.createCell(4);
cell.setCellValue("三食堂的成功建设将有效的解决学生吃饭的拥堵问题");

//返回流数据
workbook.write(os);
workbook.close();
```



## 8:导入市场活动

用户在市场活动主页面，点击"导入"按钮，弹出导入市场活动的模态窗口

用户在导入市场活动的模态窗口选择要上传的文件，点击"导入"按钮，完成导入市场活动的功能

只支持xls，文件大小不超过5MB

导入成功后，提示成功导入记录条数，关闭模态窗口，刷新市场活动列表显示第一页数据，保持每页显示条数不变

导入失败，提示信息，模态窗口不关闭，列表也不刷新

![image-20230507221218540](.\assets\image-20230507221218540.png)

后端首先拿到当前登录的用户信息，作为这些市场活动的所有者

然后拿到文件流，使用POI的那些API来解析数据，解析为一个数据就存入一个市场活动对象里面

然后把市场活动的对象存入我们的集合里，最后解析完毕则把集合作为参数传给Mapper进行批量插入

返回的JSON数据只需要提示批量插入成功的条数即可

![image-20230507222109182](.\assets\image-20230507222109182.png)

## 9:查看市场活动明细

用户在市场活动主页面，点击市场活动名称超级链接，跳转到明细页面，完成查看市场活动明细的功能

在市场活动明细页面，展示：

市场活动的基本信息

该市场活动下所有的备注信息



我们在市场活动的首页里面分页查询的时候已经动态拼接了每个市场活动名称点击的时候就是超链接

超链接的地址：workbench/activity/toDetail?id=activityId

主要就是查询市场活动的信息和备注信息，然后存入request域里面即可

![image-20230507223648685](.\assets\image-20230507223648685.png)

我们在前端已经写好了渲染数据的代码，也就是取出 request 域的数据进行渲染



## 10:添加市场活动备注

用户在市场活动明细页面，输入备注内容，点击"保存"按钮，完成添加市场活动备注的功能

备注内容不能为空

添加成功之后，清空输入框，刷新备注列表

添加失败，提示信息，输入框不清空，列表也不刷新



主要就是写数据，数据格式的校验，然后把市场活动 ID 和我们的备注文本作为参数发送给服务端

服务端接收之后插入数据，填充一些其他的字段，例如创建人，创建时间，生成ID等

插入数据，成功之后返回我们的这个备注信息对象作为JSON返回对象的数据域

然后动态拼接我们的数据，赋值给备注信息的DIV，添加到它的后面，然后清空填写的数据域即可



## 11:删除市场活动备注

用户在市场活动明细页面，点击"删除"市场活动备注的图标，完成删除市场活动备注的功能

删除成功之后，刷新备注列表

删除失败，提示信息，备注列表不刷新



这里是两个图标，名字分别是editA 和 deleteA，它们所在的外层有一个 DIV 的 ID是 remarkListDivFather

![image-20230507230414723](.\assets\image-20230507230414723.png)

![image-20230508091344599](.\assets\image-20230508091344599.png)

也就是使用拿到市场活动备注的ID，然后执行删除操作，返回JSON信息即可

## 12:修改市场活动备注

用户在市场活动明细页面，点击"修改"市场活动备注的图标，弹出修改市场活动备注的模态窗口

用户在修改市场活动备注的模态窗口，填写表单，点击"更新"按钮，完成修改市场活动备注的功能

备注内容不能为空

修改成功之后，关闭模态窗口，刷新备注列表

修改失败，提示信息，模态窗口不关闭，列表也不刷新



也就是拿到我们的市场活动备注ID，修改内容即可，修完成功再进入市场活动的详情页即可

![image-20230508093942813](.\assets\image-20230508093942813.png)

![image-20230508094033834](.\assets\image-20230508094033834.png)

# 潜在客户

## 1:去往线索

![image-20230508104107018](.\assets\image-20230508104107018.png)

主要就是查询线索里面会用到的数据字典数据和用户的信息，存入域，方便他们进行下拉框的选择

## 2:线索的分页请求

```js
sendClueRequestForPage = function (pageNo, pageSize)
```

参数主要是搜索栏的那几个参数，去线索页的时候已经把数据进行渲染了，只需要选择即可

```js
// 参数有名称，所有者，线索来源，线索状态，参数准备后发送请求
var name = $("#clueNameForPage").val().trim();
var owner = $("#clueOwnerForPage").val();
var source = $("#clueSourceForPage").val();
var state = $("#clueStateForPage").val();
```

思路就是：直接拿到这些参数，然后发送 Ajax 请求即可

![image-20230508104557671](.\assets\image-20230508104557671.png)

发送请求，后台进行处理，也就是几张表的连表查询，返回的是符合条件的数据和数据的总条数

![image-20230508104757475](.\assets\image-20230508104757475.png)

SQL的语句如下：其实就是多表联查，返回结果

```sql
<!-- 查询所有符合条件的线索列表 -->
<select id="selectClueByConditionForPage" resultType="com.zzx.crm.workbench.pojo.Clue">
    select clue.id,clue.fullname,clue.company,clue.phone,clue.mphone,
           user.name as owner,
           dicValue1.value as state,
           dicValue2.value as source
    from tbl_clue clue
    join tbl_user user on user.id = clue.owner
    join tbl_dic_value dicValue1 on dicValue1.id = clue.state
    join tbl_dic_value dicValue2 on dicValue2.id = clue.source
    <where>
        <if test="owner!=null and owner!=''">
            user.id = #{owner}
        </if>
        <if test="state!=null and state!=''">
            and clue.state = #{state}
        </if>
        <if test="source!=null and source!=''">
            and clue.source = #{source}
        </if>
        <if test="name!=null and name!=''">
            and clue.fullname like "%"#{name}"%"
        </if>
    </where>
    order by clue.create_time desc
    limit #{beginIndex},#{pageSize}
</select>
```

还有一个SQL语句就是使用 count(*) 来求所有的总记录数

成功之后动态拼接字符串，使用 $("#clueBodyForPage").html(htmlStr) 来赋值即可

## 3:创建线索

用户在线索主页面，点击”创建”按钮，弹出创建线索的模态窗口

用户在创建线索的模态窗口，填写表单，点击”保存”按钮，完成创建线索的功能

所有者、称呼、线索状态、线索来源是动态的，进行表单验证

创建成功之后，关闭模态窗口，刷新线索列表，显示第一页数据，保持每页显示条数不变

创建失败，提示信息，模态窗口不关闭，列表也不刷新



思路：就是前端点击创建，弹出模态窗口，填写数据，使用Jquery来拿到数据，进行数据格式的校验，作为参数发送Ajax请求，后台接收到参数进行封装为线索对象，赋值其它的字段，插入数据库，返回JSON数据，得到JSON数据解析，发现成功之后则关闭模态窗口，清空填写数据的表单，再发送分页请求即可，这个没什么好说的，一样和市场活动一样，需要给我们的单选框和复选框绑定关系，在之前的市场活动里面有，不再赘述

## 4:删除线索

![image-20230508105818509](.\assets\image-20230508105818509.png)

前端拿到所有单选框的ID值，后端使用字符串数组接收即可，然后执行SQL删除

![image-20230508105951583](.\assets\image-20230508105951583.png)



## 5:查询线索

当线索主页面加载完成之后，显示所有数据的第一页

用户在线索主页面填写查询条件，点击"查询"按钮，显示所有符合条件的数据的第一页

实现翻页功能

在线索主页面，显示市场活动列表和记录的总条数

默认每页显示条数:10



这个就是在页面加载之后发送分页请求，也就是我们之前写的分页请求，不再赘述

 

## 6:修改线索

1：先获取数据

```js
var editCheckbox = $("#clueBodyForPage input[type='checkbox']:checked");
if (editCheckbox.size() == 0) {
    alert("你还没有选中要修改的数据");
    return;
}
if (editCheckbox.size() != 1) {
    alert("每次只能修改一条潜在客户信息");
    return;
}
var id = editCheckbox[0].value;
```

就把这个ID作为参数去执行查询操作，然后填写表单发送更新

![image-20230508111021405](.\assets\image-20230508111021405.png)

这个时候返回了JSON数据

![image-20230508111111582](.\assets\image-20230508111111582.png)

我们的这些 owner，status，source 下面有数据，我们在去往首页的时候已经有数据了

然后我们把这些 ID 渲染过去，根据ID匹配到了就展现我们的数据，并且展现模态窗口



2：这个时候更新数据，就填写表单，发送请求，更新成功则关闭模态窗口，重新发送分页请求

## 7:查看线索明细

用户在线索主页面，点击线索名称超级链接，跳转到线索明细页面，完成查看线索明细的功能

在线索明细页面，展示：

线索的基本信息

线索的备注信息

跟该线索相关联的市场活动信息



也就是去往 detail 的页面，在这里我们需要查询

1：线索的展示信息

2：线索的备注信息

3：所关联的市场活动信息



第一个SQL，查询线索的信息，多表联查，涉及所有者，创建者，修改者，线索状态，线索来源【五张表】

![image-20230508112132143](.\assets\image-20230508112132143.png)

第二个SQL，查询备注信息，可能涉及创建者和修改者【两张表】

![image-20230508113431326](.\assets\image-20230508113431326.png)

第三个SQL，查询线索所关联的市场活动，涉及所有者，创建者，更新者，线索和市场活动的关系【四张表】

![image-20230508113843077](.\assets\image-20230508113843077.png)

4：最后存入 request 作用域里面即可

```java
request.setAttribute("clue", clue);
request.setAttribute("clueRemarkList", clueRemarkList);
request.setAttribute("activityList", activityList);
return "workbench/clue/detail";
```

在我们的 JSP 页面里面进行数据渲染即可

## 8:线索关联市场活动

用户在线索明细页面，点击"关联市场活动"按钮，弹出线索关联市场活动的模态窗口

用户在线索关联市场活动的模态窗口，输入搜索条件，每次键盘弹起，根据名称模糊查询市场活动

把所有符合条件的市场活动显示到列表中用户选择要关联的市场活动

点击"关联"按钮，完成线索关联市场活动的功能

每次至少关联一个市场活动

同一个市场活动只能跟同一个线索关联一次

关联成功之后，关闭模态窗口，刷新已经关联过的市场活动列表

关联失败，提示信息，模态窗口不关闭，已经关联过的市场活动列表也不刷新





思路：

用户点击关联市场活动，查询当前线索未关联的市场活动，然后弹出模态窗口，展现数据

用户输入条件，触发事件，查询符合条件的未关联的市场活动，然后展现数据

查询线索未关联的市场活动，涉及所有者，线索市场活动关系表【三张表】



SQL 的思路：先查询处当前线索所关联的市场活动的ID列表

select activity_id from tbl_clue_activity_relation where clud_id = clueId

再查询市场活动表，条件是市场活动的ID 不在 上面的查询结果内

select * from tbl_activity where id not in (上面的结果)

![image-20230508114933076](.\assets\image-20230508114933076.png)

查询成功之后动态拼接字符串，进行模态窗口的数据渲染

![image-20230508115537275](.\assets\image-20230508115537275.png)

如果填写了搜索的参数值，则 like 就会执行，否则就是查询全部，都是使用的同一个接口

这个时候就展现了所有的符合条件的，并且未关联的市场活动，并且动态拼接字符串到了模态窗口

还要整合单选框和复选框的按钮事件，和之前一样，也就是全选和单选的关系



用户进行选择，就选中了市场活动的ID，确认则进行线索转换

![image-20230508154224476](.\assets\image-20230508154224476.png)

参数就是一串字符串，是这种类型的

```
activityId=53e5707f91e14cdbbe4fef70702b6d87&activityId=c37e6e7ba575460193fc5c5e8cfd0299
&clueId=b0e48f047c2640798544d645b0c752f8
```

后台直接使用 String[] activityId，String clueId 接收即可

然后后台拿到用户传递的市场活动ID列表，封装成为一个个的市场活动线索关系对象，把对象存入集合

最后批量插入市场活动线索表即可

![image-20230508154457563](.\assets\image-20230508154457563.png)

SQL语句倒是没什么，遍历集合，插入数据即可

![image-20230508154615023](.\assets\image-20230508154615023.png)

## 9:解除线索关联市场活动

用户在线索明细页面，点击某一个"解除关联"按钮，弹出确认解除的窗口

用户点击"确定"按钮，完成解除线索关联市场活动的功能

解除成功之后，刷新已经关联的市场活动列表

解除失败，提示信息，列表也不刷新



就是拿到我们的市场活动ID以及线索的ID，作为参数，执行删除关联关系表的操作即可

![image-20230508155314855](.\assets\image-20230508155314855.png)

对应的SQL语句

![image-20230508155254170](.\assets\image-20230508155254170.png)

## 10:线索转换

用户在线索明细页面，点击"转换"按钮，跳转到线索转换页面

用户在线索转换页面，如果需要创建创建交易，则填写交易表单数据，点击"转换"按钮，完成线索转换的功能

在线索转换页面，展示：fullName，appellation，company，owner

市场活动源是可搜索的

数据转换:

把线索中有关公司的信息转换到客户表中

把线索中有关个人的信息转换到联系人表中

把线索的备注信息转换到客户备注表中一份

把线索的备注信息转换到联系人备注表中一份

把线索和市场活动的关联关系转换到联系人和市场活动的关联关系表中

如果需要创建交易，还要往交易表中添加一条记录 

如果需要创建交易，还要把线索的备注信息转换到交易备注表中一份

删除线索的备注

删除线索和市场活动的关联关系

删除线索

在一同个事务中完成

转换成功之后，跳转到线索主页面

转换失败，提示信息，页面不跳转





在页面内点击转换为真实客户，实际上是一个超链接：workbench/clue/toConvert?id=${clue.id}

![image-20230508155731237](.\assets\image-20230508155731237.png)

这里主要是把线索的信息查出来以及一个数据字典类型的所有值查出来，存入域供我们选择

当我们点击线索转换按钮的时候，需要把该线索关联的市场活动全部查询出来

当我们输入内容的时候，触发事件，需要把符合该条件且关联的市场活动全部查询出来

![image-20230508161200281](.\assets\image-20230508161200281.png)

查询出来之后，动态拼接字符串，放入我们的模态窗口的数据内