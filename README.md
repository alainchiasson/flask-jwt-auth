# Testing an API gateway in python

These are notes from going through the tutorial at : https://www.bacancytechnology.com/blog/flask-jwt-authentication

# Not using postman 

Register the user:

    curl -X POST -H "Content-Type: application/json" --data "@user.json"  http://localhost:5000/register

We can view the user data - this is simple data :

    root@021fc1b9dc40:/usr/src# curl -X GET  http://localhost:5000/users

Returned : 

```json
{
  "users": [
    {
      "admin": false,
      "name": "alain",
      "password": "sha256$xRKNtc353a0BN1lO$954ece38c0b427576f47ce87f31bf2ae1db9a04b843494c1f003c29667ace697",
      "public_id": "a0985054-13d5-4329-b793-7a8e81516bde"
    }
  ]
}
```

# Authenticate and perform actions

login to get a session :

    curl -v -X POST  http://alain:pwd@localhost:5000/login

In the rerturn, you get a token:

```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfaWQiOiJhMDk4NTA1NC0xM2Q1LTQzMjktYjc5My03YThlODE1MTZiZGUiLCJleHAiOjE2NjMyNDE4MzV9.We3zdvDlJ9B3AYjMTjFelvZNA8dSmiugm6K_Wv6wu50"
}
```

so use it to push data:

    curl -X POST -H "x-access-tokens: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfaWQiOiJhMDk4NTA1NC0xM2Q1LTQzMjktYjc5My03YThlODE1MTZiZGUiLCJleHAiOjE2NjMyNDA2ODh9.1qLWmpYSiTutw2I2aeTGZpQRb3iAogUgoH4-ih9qQn8"  -H "Content-Type: application/json" --data "@book1.json" http://localhost:5000/book

Then list the data : 

    curl -X GET -H "x-access-tokens: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfaWQiOiJhMDk4NTA1NC0xM2Q1LTQzMjktYjc5My03YThlODE1MTZiZGUiLCJleHAiOjE2NjMyNDA2ODh9.1qLWmpYSiTutw2I2aeTGZpQRb3iAogUgoH4-ih9qQn8"  http://localhost:5000/books

But this fails, as it is not authenticated : 

    curl -X GET  http://localhost:5000/books

Now to delete :

    curl -X DELETE -H "x-access-tokens: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfaWQiOiJhMDk4NTA1NC0xM2Q1LTQzMjktYjc5My03YThlODE1MTZiZGUiLCJleHAiOjE2NjMyNDA2ODh9.1qLWmpYSiTutw2I2aeTGZpQRb3iAogUgoH4-ih9qQn8"  http://localhost:5000/books/1

Ok that last one has an error that is fixable : sqlalchemy.exc.InvalidRequestError: Object '<Books at 0x7f2634ccff10>' is already attached to session '13' (this is '14')


# How it works 

This is an overly simplified example, but. after the user is registered/provisionned. On login, the hash of the sent password is verified with the hash stored in the DB ( not this is not Encrypted ):

   if check_password_hash(user.password, auth.password):
       token = jwt.encode({'public_id' : user.public_id, 'exp' : datetime.datetime.utcnow() + datetime.timedelta(minutes=45)}, app.config['SECRET_KEY'], "HS256")
 
       return jsonify({'token' : token})

If this correct, a JSON token is created with the PUBLIC user ID (generated at registration) and a 45 minute expiration. This token is returned.

On subsequent calls, the validity of the token is tested, This will get used by the decorator function :

    data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])

The extracted data  is used :

    current_user = Users.query.filter_by(public_id=data['public_id']).first()

    return f(current_user, *args, **kwargs)

And the other functions will use the extracted data. :

    @token_required
    def create_book(current_user):

# Other Notes

This is an Oversimplified example, but shows what the integration point for a API token service could be.