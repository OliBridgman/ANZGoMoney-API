# ANZ GoMoney API v2.0

## Notes

I did this purely for a bit of fun. I checked out the older API when ANZ and National Bank were seperate, I thought it would be fun to check out v2 of the API.

This is all accessable by anyone by simply proxying your device through something like Charles Proxy.

I found it interesting that the app adds `rooted` to the user-agent header if you're on a jailbroken device, and even warns you on the device. I didn't need to jailbreak to find this information out.

Everything seems to be `Content-Type: application/json`

## Base URL

`https://secure.anz.co.nz/api/v2`

Then every request is split between `/u` and `/s`. 
Sessions get managed with `/u` and data is pulled from `/s`. 

So I don't know what they stand for? (User/Service maybe)

## Authentication

Each client application has it's own API key as far as I can tell. This will most likely be hard coded into the app (or generated first launch, and stored in the keychain as it seems to be constant through re-installs - must check on Android)

API Key for the iOS Client: `3094fe62-0d4e-4e59-bb13-8dee1bdac934`

API Key for the Android Client: `?`

This API Key is included in every HTTP request to the server in the header fields as `Api-Key`.

When we make a call to `/u/session` we get sent a cookie that we must set.

## Calls
### Login using userId and password
Pretty simple. Use your online banking userid and password.
	
	POST /u/sessions
	{
		"userId": "xxxxxxxx",
		"password": "xxxxxxxxx"
	}
	

The server will return a json object like so
	
	200
	{
		"goMoney": {
			"registrationStatus": {
				"pinSetup": true,
				"p2mNumberSetup": true,
				"p2mNumberNeedsVerification": false,
				"p2mAccountSetup": true,
				"p2mUncollectedPayments": false
			},
			"messageOverrides": {},
			"isCurrentVersion": true
		},
		"billPayments": {
			"upcomingHolidays": [{
				"description": "Christmas Day",
				"date": "2013-12-25"
			}, {
				"description": "Boxing Day",
				"date": "2013-12-26"
			}, {
				"description": "New Years Day",
				"date": "2014-01-01"
			}, {
				"description": "Day after New Years Day",
				"date": "2014-01-02"
			}, {
				"description": "Waitangi Day",
				"date": "2014-02-06"
			}],
			"maxDaysInFuture": 90,
			"cutoffTime": "2200",
			"immediatePayments": {
				"validBankCodes": ["01", "06", "11"],
				"exemptAccountPrefixes": ["01-0102-xxxxxxx", "01-0102-xxxxxxx", "01-0102-xxxxxxx", "01-0202-xxxxxxx", "01-0058-xxxxxxx", "01-0070-xxxxxxx", "01-0126-xxxxxxx", "06-0580-xxxxxxx", "06-0580-xxxxxxx", "06-0986-xxxxxxx", "06-0986-xxxxxxx", "06-0986-xxxxxxx", "11-8431-xxxxxxx", "06-0801-xxxxxxx", "01-0102-xxxxxxx", "01-0102-xxxxxxx", "01-1820-xxxxxxx"]
			},
			"commonPayees": {
				"ird": "03-0049-xxxxxxx-27",
				"acc": "03-0502-xxxxxxx-09"
			},
			"limits": {
				"channelBpLimit": "10000.00",
				"customerLimits": [{
					"customerKey": "xxxxxxxx",
					"customerBpLimit": "5000.00"
				}]
			}
		},
		"p2m": {
			"p2mLimit": "1000.00",
			"messageLength": 30,
			"fromNameLength": 20,
			"toNameLength": 50
		},
		"userInfoMessages": [],
		"payees": [{
		"customerKey": "xxxxxxxx",
		"canCreatePayees": true,
		"canDeletePayees": true
		}],
		"clientExpiryDate": "2025-01-01T00:00:00.000+1300",
		"customerSelect": {
			"customers": [{
				"customerKey": "xxxxxxxx",
				"customerName": "MR YOUR NAME",
				"primaryCustomer": true,
				"customerIdHash": "?SHA-2 HASH?"
			}]
		},
		"httpStatus": 200,
		"serverDateTime": "2013-12-23T22:53:42.929+1300"
	}

Lot's of things!

So this call gets you some information about the user but we can't make calls yet as we need to setup a device pin, which is all done serverside.

### Login using pin and deviceToken
Once we have a `deviceToken	` and have setup our `pin` we can use these to login.
Similar to the first call just call

	POST /u/sessions
	{
		"deviceToken": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
		"pin": "xxxx"
	}
	
The server will return the same response as the first login.


### Verify Pin
To verify a pin number, or set one up to get a device token make the following call

	POST /s/pins/verify
	{
		"pin": "xxxx",
		"newDevice": {
			"description": "[iPhone6,1]"
		}
	}

The server will respond with

	200
	{
		"newDevice": {
			"key": "xxxxxxxx",
			"deviceToken": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
		},
		"httpStatus": 200,
		"serverDateTime": "2013-12-23T22:53:46.830+1300"
	}

Now we have set the `pin` and we have the `deviceToken`. We can authenticate without our username and password now!

### Accounts
List all the accounts of the user

	GET /s/accounts

The server will respond with a JSON object containing the serverTime, httpStatus, invalidTransfers and an Array of Account objects

	200
	{
		"serverDateTime": "",
		"httpStatus": 200,
		"invalidTransfers": [],
		"accounts": [{
			"key": "xxxxxxxx",
			"customerKey": "xxxxxxxx",
			"accountNumber": "xx-xxxx-xxxxxxx-xx",
			"productName": String,
			"nickname": String,
			"balance": "0.00",
			"available": "0.00",
			"ownerName": "MR xxxxxxxx",
			"transferSource": true,
			"transferDest": true,
			"p2mSource": true,
			"p2mDest": true,
			"allowPayments": true,
			"hashedAccountNumber": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
			"overdraftLimit": "0.00",
			"p2mAccount": true,
			"ableToPayUnsavedPayee": true,
			"type": "current",
			"pieAccount": false,
			"hasTransactionHistory": true,
			"cashAdvanceAccount": false
		}]
	}

#### Account Object

| Field Name | Type | Explanation |
| ---------- | ---- | ----------- |
| key | String | 8 Character Key |
| customerKey | String | 8 Character Key |
| accountNumber | String | The account number |
| productName | String | Human readable account type |
| nickname | String | The account's nickname as set using the online banking website |
| balance | String/Float | Balance of the account |
| avaliable | String/Float | Avaliable balance of the account |
| ownerName | String | Account owners name |
| transferSource | Boolean | Whether or not we can transfer from this account |
| transferDest | Boolean | Whether or not we can transfer to this account |
| p2mSource | Boolean | |
| p2mDest | Boolean | |
| allowPayments | Boolean | |
| hashedAccountNumber | String | Not sure what hash function is used |
| overdraftLimit | String/Float | |
| p2mAccount | Boolean | |
| ableToPayUnsavedPayee | Boolean | |
| type | String | Type of account |
| pieAccount | Boolean | Unsure |
| hasTransactionHistory | Boolean | |
| cashAdvancedAccount | Boolean | |

### Get Transactions

Get a list of transactions for an account.

	GET /s/transactions/<AccountKey>/<FromDate>/<ToDate>
	
	eg
	GET /s/transactions/xxxxxxxx/2013-10-27/2013-12-25
	
The server will respond with 

	200
	{
		"serverDateTime": "",
		"httpStatus": 200,
		"transactions": [{
			"date": "2013-10-29",
			"details": ["Detail 1", "Detail 2", "Detail 3"],
			"debitAmount": "2535.50",
			"type": "Visa Purchase",
			"balance": "23542345.32"
		}]
	}

#### Transaction Object

| Field Name | Type | Explanation |
| ---------- | ---- | ----------- |
| date | String | YYYY-MM-DD |
| details | Array | An array of Strings |
| debitAmount | String/Float | How much was spent |
| type | String | Type of transaction |
| balance | String/Float | Balance of account after this transaction |

## Transfer Between Accounts
Transfer money between your accounts

	POST /s/transfers
	{
		"amount": "1.00",
		"toAccountKey": "xxxxxxxx",
		"fromAccountKey": "xxxxxxxx"
	}

If it was successful the server will respond with

	200
	{
		"httpStatus": 200,
		"serverDateTime": "2013-12-24T22:54:39.537+1300",
	}
	

## Transfer to Another Bank Account

To Investigate
