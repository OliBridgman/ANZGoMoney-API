# ANZ GoMoney API v5.0

It's been about 2 years and the previous version of this document must be out of date. There has been 3 more versions of the API as it currently appears to be Version 5.

I'm slowly making a Swift API framework to help myself learn Swift 2.0 (and maybe write some tests!) with the aim to make a watch app that can show my balances and allow me to transfer "fast cash" from one account to another at the touch of a button. ⌚️💸

## Note to ANZ
You should *really* make a public API that people can consume.

Currently no NZ bank do this and it'll really be a way for you to differentiate yourselves. People could come up with all sorts of awesome things which strengthens you as a choice of bank!

[DO IT](https://www.youtube.com/watch?v=ZXsQAXx_ao0) (In the nicest way possible)

## Build

Clone the repository, then run `pod install`, opening the generated Xcode workspace.

Rename the Private.swift.template to Private.swift and fill in with your details (for now). This file has been gitignored to ensure I don't leak my details out.

## Base URL

This is all accessable by anyone by simply proxying your device through something like Charles Proxy.

I found it interesting that the app adds `rooted` to the user-agent header if you're on a jailbroken device, and even warns you on the device. I didn't need to jailbreak to find this information out.

Everything seems to be `Content-Type: application/json`

`https://secure.anz.co.nz/api/v5`

Then every request is split between `/u` and `/s`.
Sessions get managed with `/u` and data is pulled from `/s`.

So I don't know what they stand for? (User/Service maybe)

## Authentication

Each client application has it's own API key as far as I can tell. This will most likely be hard coded into the app (or generated first launch, and stored in the keychain as it seems to be constant through re-installs - must check on Android)

API Key for the iOS Client: `9b415be2-1a04-493c-b0e7-7895c6242698`

API Key for the Android Client: `?`

This API Key is included in every HTTP request to the server in the header fields as `Api-Key`.

When we make a call to `/u/session` we get sent a cookie that we must set.

I haven't checked if the API requires a known user agent but the app uses `goMoney NZ/4.6.0/Wifi/iPhone7,2/9.0/`

## Headers

	Api-Key: 9b415be2-1a04-493c-b0e7-7895c6242698
	Request-Tag: PwGuest
	Content-Type: application/json
	User-Agent: goMoney NZ/4.6.0/Wifi/iPhone7,2/9.0/
	Api-Request-Id: AEF5A3FA-35CA-451B-A995-B26F8EF95954

Api-Request-Id appears to be a random UUID generated by the clients for logging I presume.

## Error Handling

Let's figure out how errors appear to be handled.

Sometimes we simply get a code back

	{
		"code": "E884125"
	}

Usually we get a structured response

	{
		"code": "loginDenied",
		"devDescription": "The user cannot log in - e.g. credentials were incorrect, account is locked, etc",
		"sinceVersion": 5,
		"httpStatus": 401,
		"serverDateTime": "2015-08-28T13:40:31.910+1200",
		"suppressed": []
	}

And sometimes we get the same result as above but with some data to be used in the 'next step'

	{
		"code": "authCodeSent",
		"devDescription": "The Auth Code has been sent to the client, please send the request with this code.",
		"sinceVersion": 5,
		"httpStatus": 400,
		"errorParameters": {
			"oneTimePassword": "gauP8S4w9FiF/f1aIjxdJhkclixAdR",
			"maskedMobilePhoneNumber": "******1234"
		},
		"serverDateTime": "2015-08-28T13:45:59.533+1200"
	}

### Error Codes

I've started to compile a list of error codes

| Error Code | Status Code | Dev Description |
| ---------- | ---- | ----------- |
| loginDenied | 401 | The user cannot log in - e.g. credentials were incorrect, account is locked, etc |
| authCodeSent | 400 | The Auth Code has been sent to the client, please send the request with this code. |
| tooManySessions | 403 | The user already has more than the maximum allowed number of sessions |
| E111898 | 401 | null |
| E884125 | 403 | null |

## Calls
### Login using userId and password
Pretty simple. Use your online banking userid and password.

	POST /u/sessions
	{
		"userId": "12345678",
		"password": "password"
	}

If you have setup OnlineCode then you will get a 400 json respose as follows

	{
		"code": "authCodeSent",
		"devDescription": "The Auth Code has been sent to the client, please send the request with this code.",
		"sinceVersion": 5,
		"httpStatus": 400,
		"errorParameters": {
			"oneTimePassword": "gauP8S4w9FiF/f1aIjxdJhkclixAdR",
			"maskedMobilePhoneNumber": "******1234"
		},
		"serverDateTime": "2015-08-24T18:07:43.794+1200"
	}

Which you then make another request to the same endpoint like so

	POST /u/sessions
	{
		"oneTimePassword": "gauP8S4w9FiF/f1aIjxdJhkclixAdR"
		"userId": "12345678",
		"authCode": "1234"
	}

The server will return a json object like so

	{
		"httpStatus": 200,
		"serverDateTime": "2015-08-24T18:07:57.207+1200",
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
		"payments": {
			"billPayments": {
				"cutoffTime": "2200",
				"immediatePayments": {
					"validBankCodes": ["01", "06", "11"],
					"exemptAccountPrefixes": ["01-0102-xxxxxxx-01", "01-0102-xxxxxxx-01", "01-0102-xxxxxxx-01", "01-0202-xxxxxxx-03", "01-0731-xxxxxxx-00", "01-0731-xxxxxxx-01", "01-0058-xxxxxxx-05", "01-0070-xxxxxxx-00", "01-0126-xxxxxxx-00", "06-0580-xxxxxxx-01", "06-0580-xxxxxxx-00", "06-0986-xxxxxxx-00", "06-0986-xxxxxxx-03", "06-0986-xxxxxxx-00", "11-8431-xxxxxxx-00", "06-0801-xxxxxxx-08", "01-0102-xxxxxxx-01", "01-0102-xxxxxxx-03", "01-1820-xxxxxxx-00"]
				},
				"limits": {
					"channelLimit": "10000.00",
					"customerLimits": [{
						"customerKey": "xxxxxxxx",
						"customerLimit": "5000.00"
					}]
				}
			},
			"automaticPayments": {
				"cutoffTime": "2000",
				"maximumDeleteAmount": "10000.00",
				"maxFirstPaymentDate": "2016-08-24",
				"maxLastPaymentDate": "2020-08-24",
				"validFrequencies": [{
					"code": "D0700",
					"displayText": "Weekly"
				}, {
					"code": "D1400",
					"displayText": "Fortnightly"
				}, {
					"code": "D2800",
					"displayText": "Every 4 weeks"
				}, {
					"code": "M0100",
					"displayText": "Monthly"
				}, {
					"code": "D5600",
					"displayText": "Every 8 weeks"
				}, {
					"code": "D8400",
					"displayText": "Every 12 weeks"
				}, {
					"code": "Q0000",
					"displayText": "Quarterly"
				}, {
					"code": "S0000",
					"displayText": "Semi annually"
				}, {
					"code": "A0000",
					"displayText": "Annually"
				}],
				"limits": {
					"channelLimit": "10000.00",
					"customerLimits": [{
						"customerKey": "xxxxxxxx",
						"loadAmount": "1000.00",
						"amendAmount": "1000.00"
					}]
				}
			},
			"commonPayees": {
				"ird": "03-0049-0001100-27",
				"acc": "03-0502-0287400-09"
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
		"customerSelect": {
			"customers": [{
				"customerKey": "xxxxxxxx",
				"customerName": "MR WILLIAM TOWNSEND",
				"primaryCustomer": true,
				"customerIdHash": "xxxxxxxx"
			}]
		},
		"notifications": [{
			"notificationKey": 841xxxx,
			"subject": "Your latest CREDIT CARD statement is available. Closing balance: $0.00",
			"message": "No payment is required. [<transactions?accountUuid=`VS000000000000000000043677xxxxxx`&tab=edocStatementsTab|View statement>]",
			"type": "CCSTMT",
			"expiryDate": "2015-09-22"
		}],
		"qbEnabled": true,
		"ibSessionId": "00c2xxxx-xxxx-xxxx-xxxx-xxxx1d121966",
		"cardPinStatus": "ON",
		"futureDatedBillPaymentsAndTransactions": {
			"upcomingHolidays": [{
				"description": "Labour Day",
				"date": "2015-10-26"
			}],
			"maxDaysInFuture": 90
		}
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

I am not 100% sure where the device token comes from.

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
