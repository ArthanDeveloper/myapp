class LoanDetailsObject {
  int? apiCode;
  String? apiDesc;
  String? name;
  EncoreAccountSummary? encoreAccountSummary;
  List<AccountStatements>? accountStatements;
  DueDetails? dueDetails;

  LoanDetailsObject(
      {this.apiCode,
        this.apiDesc,
        this.name,
        this.encoreAccountSummary,
        this.accountStatements,
        this.dueDetails});

  LoanDetailsObject.fromJson(Map<String, dynamic> json) {
    apiCode = json['apiCode'];
    apiDesc = json['apiDesc'];
    name = json['name'];
    encoreAccountSummary = json['encoreAccountSummary'] != null
        ? new EncoreAccountSummary.fromJson(json['encoreAccountSummary'])
        : null;
    if (json['accountStatements'] != null) {
      accountStatements = <AccountStatements>[];
      json['accountStatements'].forEach((v) {
        accountStatements!.add(new AccountStatements.fromJson(v));
      });
    }
    dueDetails = json['dueDetails'] != null
        ? new DueDetails.fromJson(json['dueDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['apiCode'] = this.apiCode;
    data['apiDesc'] = this.apiDesc;
    data['name'] = this.name;
    if (this.encoreAccountSummary != null) {
      data['encoreAccountSummary'] = this.encoreAccountSummary!.toJson();
    }
    if (this.accountStatements != null) {
      data['accountStatements'] =
          this.accountStatements!.map((v) => v.toJson()).toList();
    }
    if (this.dueDetails != null) {
      data['dueDetails'] = this.dueDetails!.toJson();
    }
    return data;
  }
}

class EncoreAccountSummary {
  String? accountId;
  String? productType;
  String? productCode;
  String? accountName;
  String? branchCode;
  String? branchName;
  String? glSubHead;
  String? normalInterestRate;
  String? operationalMode;
  String? operationalStatus;
  String? valueDateStr;
  String? customerId1;
  String? customer1FirstName;
  String? customer1MiddleName;
  String? customer1LastName;
  Null? name;
  String? amount;
  String? tenureMagnitude;
  String? tenureUnit;
  String? tenureUnitShort;
  String? accountOpenDateStr;
  String? udfText1;
  String? udfText5;
  String? udfText6;

  EncoreAccountSummary(
      {this.accountId,
        this.productType,
        this.productCode,
        this.accountName,
        this.branchCode,
        this.branchName,
        this.glSubHead,
        this.normalInterestRate,
        this.operationalMode,
        this.operationalStatus,
        this.valueDateStr,
        this.customerId1,
        this.customer1FirstName,
        this.customer1MiddleName,
        this.customer1LastName,
        this.name,
        this.amount,
        this.tenureMagnitude,
        this.tenureUnit,
        this.tenureUnitShort,
        this.accountOpenDateStr,
        this.udfText1,
        this.udfText5,
        this.udfText6});

  EncoreAccountSummary.fromJson(Map<String, dynamic> json) {
    accountId = json['accountId'];
    productType = json['productType'];
    productCode = json['productCode'];
    accountName = json['accountName'];
    branchCode = json['branchCode'];
    branchName = json['branchName'];
    glSubHead = json['glSubHead'];
    normalInterestRate = json['normalInterestRate'];
    operationalMode = json['operationalMode'];
    operationalStatus = json['operationalStatus'];
    valueDateStr = json['valueDateStr'];
    customerId1 = json['customerId1'];
    customer1FirstName = json['customer1FirstName'];
    customer1MiddleName = json['customer1MiddleName'];
    customer1LastName = json['customer1LastName'];
    name = json['name'];
    amount = json['amount'];
    tenureMagnitude = json['tenureMagnitude'];
    tenureUnit = json['tenureUnit'];
    tenureUnitShort = json['tenureUnitShort'];
    accountOpenDateStr = json['accountOpenDateStr'];
    udfText1 = json['udfText1'];
    udfText5 = json['udfText5'];
    udfText6 = json['udfText6'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accountId'] = this.accountId;
    data['productType'] = this.productType;
    data['productCode'] = this.productCode;
    data['accountName'] = this.accountName;
    data['branchCode'] = this.branchCode;
    data['branchName'] = this.branchName;
    data['glSubHead'] = this.glSubHead;
    data['normalInterestRate'] = this.normalInterestRate;
    data['operationalMode'] = this.operationalMode;
    data['operationalStatus'] = this.operationalStatus;
    data['valueDateStr'] = this.valueDateStr;
    data['customerId1'] = this.customerId1;
    data['customer1FirstName'] = this.customer1FirstName;
    data['customer1MiddleName'] = this.customer1MiddleName;
    data['customer1LastName'] = this.customer1LastName;
    data['name'] = this.name;
    data['amount'] = this.amount;
    data['tenureMagnitude'] = this.tenureMagnitude;
    data['tenureUnit'] = this.tenureUnit;
    data['tenureUnitShort'] = this.tenureUnitShort;
    data['accountOpenDateStr'] = this.accountOpenDateStr;
    data['udfText1'] = this.udfText1;
    data['udfText5'] = this.udfText5;
    data['udfText6'] = this.udfText6;
    return data;
  }
}

class AccountStatements {
  String? balance;
  String? accountId;
  int? valueDate;
  String? valueDateStr;
  int? transactionDate;
  String? transactionName;
  String? transactionDateStr;
  Null? referencedTransactionId;
  String? referencedAccountId;
  Null? subAccountId;
  int? entryNum;
  String? accountEntryType;
  String? amount;
  String? description;
  String? transactionId;
  String? currencyCode;
  String? debitAmount;
  String? creditAmount;
  Null? reference1;

  AccountStatements(
      {this.balance,
        this.accountId,
        this.valueDate,
        this.valueDateStr,
        this.transactionDate,
        this.transactionName,
        this.transactionDateStr,
        this.referencedTransactionId,
        this.referencedAccountId,
        this.subAccountId,
        this.entryNum,
        this.accountEntryType,
        this.amount,
        this.description,
        this.transactionId,
        this.currencyCode,
        this.debitAmount,
        this.creditAmount,
        this.reference1});

  AccountStatements.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    accountId = json['accountId'];
    valueDate = json['valueDate'];
    valueDateStr = json['valueDateStr'];
    transactionDate = json['transactionDate'];
    transactionName = json['transactionName'];
    transactionDateStr = json['transactionDateStr'];
    referencedTransactionId = json['referencedTransactionId'];
    referencedAccountId = json['referencedAccountId'];
    subAccountId = json['subAccountId'];
    entryNum = json['entryNum'];
    accountEntryType = json['accountEntryType'];
    amount = json['amount'];
    description = json['description'];
    transactionId = json['transactionId'];
    currencyCode = json['currencyCode'];
    debitAmount = json['debitAmount'];
    creditAmount = json['creditAmount'];
    reference1 = json['reference1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    data['accountId'] = this.accountId;
    data['valueDate'] = this.valueDate;
    data['valueDateStr'] = this.valueDateStr;
    data['transactionDate'] = this.transactionDate;
    data['transactionName'] = this.transactionName;
    data['transactionDateStr'] = this.transactionDateStr;
    data['referencedTransactionId'] = this.referencedTransactionId;
    data['referencedAccountId'] = this.referencedAccountId;
    data['subAccountId'] = this.subAccountId;
    data['entryNum'] = this.entryNum;
    data['accountEntryType'] = this.accountEntryType;
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['transactionId'] = this.transactionId;
    data['currencyCode'] = this.currencyCode;
    data['debitAmount'] = this.debitAmount;
    data['creditAmount'] = this.creditAmount;
    data['reference1'] = this.reference1;
    return data;
  }
}

class DueDetails {
  Null? feeDue;
  Null? demandDue;
  Null? totoalDemadDue;
  Null? daysPastDue;
  Null? operationalStatus;
  Null? equatedInstallment;

  DueDetails(
      {this.feeDue,
        this.demandDue,
        this.totoalDemadDue,
        this.daysPastDue,
        this.operationalStatus,
        this.equatedInstallment});

  DueDetails.fromJson(Map<String, dynamic> json) {
    feeDue = json['feeDue'];
    demandDue = json['demandDue'];
    totoalDemadDue = json['totoalDemadDue'];
    daysPastDue = json['daysPastDue'];
    operationalStatus = json['operationalStatus'];
    equatedInstallment = json['equatedInstallment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['feeDue'] = this.feeDue;
    data['demandDue'] = this.demandDue;
    data['totoalDemadDue'] = this.totoalDemadDue;
    data['daysPastDue'] = this.daysPastDue;
    data['operationalStatus'] = this.operationalStatus;
    data['equatedInstallment'] = this.equatedInstallment;
    return data;
  }
}