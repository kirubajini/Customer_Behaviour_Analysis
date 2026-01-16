import pandas as pd
from sqlalchemy import create_engine


df = pd.read_csv(r"C:\Users\User\Downloads\customer_shopping_behavior.csv")

print(df.head())
print(df.info())
print(df.describe(include="all"))
print(df.isnull().sum())

df['Review Rating'] = df.groupby('Category')['Review Rating'].transform(lambda x: x.fillna(x.mean()))
print(df.isnull().sum())

df.columns = df.columns.str.lower()
df.columns = df.columns.str.replace(' ', '_')
df = df.rename(columns={'purchase_amount_(usd)': 'purchase_amount'})
print(df.columns)

#create a column age_group
labels = ['Young Adults', 'Adult', 'Middle-aged', 'Senior']
df['age_group'] = pd.qcut(df['age'], 4, labels=labels)
print(df[['age', 'age_group']].head(10))

#create column purchase_frequency_days
frequency_mapping = {
    'Fortnighty' : 14,
    'Weekly' : 7,
    'Monthly' : 30,
    'Quarterly' : 90,
    'Bi-Weekly' : 14,
    'Annually' : 365,
    'Every 3 Months' : 90
}
df['purchase_frequency_days']=df['frequency_of_purchases'].map(frequency_mapping)
df[['purchase_frequency_days','frequency_of_purchases']].head(10)

print(df[['discount_applied','promo_code_used']].head(10))

(df['discount_applied'] == df['promo_code_used']).all()

#connect to SQL Server

server = "DESKTOP-JV23R4B\\MSSQLSERVER01"
database = "customer_behavior"

engine = create_engine(
    "mssql+pyodbc://@{}/{}?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
    .format(server, database)
)

df.to_sql("customer", engine, if_exists="replace", index=False)

print("Data successfully loaded into SQL Server")





