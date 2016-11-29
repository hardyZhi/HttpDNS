整体逻辑： ＜/br＞
1.启动APP去判断本应用使用的各域名是否被DNS劫持。 
2.正常情况下没被劫持的话继续用域名访问接口和WebView。 
3.如果被劫持了则使用阿里云HttpDNS服务SDK获取该域名未被劫持的正确IP存在本地。 
4.注册一个全局的NSURLProtocol去拦截所有接口request和UIWebView的request。 
5.在自定义的NSURLProtocol中把所有的request都替换成IP形式的请求来绕过DNS域名解析的过程。（例如https://jifen.2345.com/api/getRealIP.php替换成https://115.231.185.111/api/getRealIP.php）


注意的点：  
1.判断是否被劫持需要先内置一份本App使用的各域名所对应的IP地址的列表，然后每次启动时都去更新一下这个列表，因为IP地址服务器端可能会变。 
2.判断是否被劫持的逻辑是：实时获取的该域名解析出的IP和本地存储的正常IP地址是否有匹配的，如果没有匹配的就表示已被劫持了。 
3.支持所有NSURLSession/NSURLConnection这种类型的网络请求的拦截替换。 
4.NSURLProtocol不支持WKWebView的拦截，如果要支持的话只能使用私有方法。 
5.WebView的HttpDNS目前主流App都还没做，这里面有很多坑，建议只做那种纯展示的网页，无交互，无cookie之类的。 
6.为了节约成本，建议启动的时候检测到被劫持了才去阿里云拿正确的IP并存储下来本次启动用，当然土豪可以不用在乎，每次请求都重新拿一下也没问题。 


测试： 
可以使用越狱的iOS设备，绑定host来模拟DNS拦截比如：(188.57.57.37  jifen.2345.com)。 
做了HttpDNS的App就算被拦截了也能正常访问数据，没做的话就网络异常了。 
