# Testing an API gateway in python

These are notes from going through the tutorial at : https://www.bacancytechnology.com/blog/flask-jwt-authentication

# Not using postman 

curl -X POST -H "Content-Type: application/json" --data "@user.json"  http://localhost:5000/register

Follwed by :

curl -v -X POST  http://alain:pwd@localhost:5000/login

In the rerturn, you get a token :


curl -X POST -H "x-access-token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfaWQiOiI3NjJhMmU4Mi0yZDVkLTRmOTQtYWQzYi0yMzUyMTM3MWQ5OWIiLCJleHAiOjE2NjMyMzk4NjF9.r-k6IxPuifmX5ukgZXgyw99ZGXLucVqL3jp6BFfh5MY"  http://localhost:5000/book
