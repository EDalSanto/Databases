## Very Simple ![PostgreSQL](https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Postgresql_elephant.svg/1200px-Postgresql_elephant.svg.png) Clone in Ruby

* done to help understand the fundamentals of how a RDBMS, like PostgreSQL, operates under the hood, i.e., 
  * parses a SQL query 
  * generates an execution plan
  * returns the final result set

#### TODO
* binary format for data along with 8kb paging
  * started something but never finished in TableManager 
* lock manager 
* b+tree index
  * some pseudocode available in notes
* SQL parser to construct
  * define grammar
	 * construct abstract syntax tree from SQLr 
* write ahead log
* optimizer / planne
