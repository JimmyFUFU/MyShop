# Welcome to MyShop 🎉

**🌐 [Homepage](https://myshop.fujimmy.com/)**

Prerequisites
-------------------------
* ruby >= 2.6.8
* rails >= 5.0.7.2
* sqlite3 >= 3.28.0

Install
-------------------------
```bash=
git clone https://github.com/JimmyFUFU/MyShop.git
cd MyShop
bundle
rake db:migrate
rake db:seed # create products
```

Usage
-------------------------
```bash=
rails s
```
visit http://localhost:3000

Run test
-------------------------
```bash=
rspec
```

Api Docs
-------------------------
### local
visit http://localhost:3000/api-docs
  * Login at [Myshop](http://localhost:3000/)
  * Choose any api you want and click "Try it out"
  * Fill with Parameters if required
  * Click "execute"
  * Get the response

If you edit `spec/integration/*_spec.rb`, please execute `rake rswag:specs:swaggerize` to update api-docs

### Website 🌐
visit https://myshop.fujimmy.com/api-docs
  * Login at [Myshop](https://myshop.fujimmy.com/)
  * Choose any api you want and click "Try it out"
  * Fill with Parameters if required
  * Click "execute"
  * Get the response


