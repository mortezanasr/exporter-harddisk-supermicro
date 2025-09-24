# Dockerfile نهایی و صحیح

# 1. استفاده از ایمیج پایه پایتون
FROM python:3.9-slim

# 2. تعیین پوشه کاری داخل کانتینر
WORKDIR /app

# 3. کپی کردن فایل‌های پروژه
#    کپی کردن اسکریپت پایتون (با نام صحیح)
COPY storcli_exporter.py .

#    کپی کردن اسکریپت شل
COPY storcli_exporter.sh /usr/local/bin/storcli_exporter.sh

#    کپی کردن ابزار storcli64 که از فایل .deb استخراج کردیم
#    این دستور پوشه opt را از هاست به داخل کانتینر کپی می‌کند
COPY opt/MegaRAID/storcli/storcli64 /opt/MegaRAID/storcli/storcli64

# 4. اجرایی کردن فایل‌های لازم
RUN chmod +x /usr/local/bin/storcli_exporter.sh /opt/MegaRAID/storcli/storcli64

# 5. نصب پکیج‌های پایتون
RUN pip install flask

# 6. معرفی پورت (برای اطلاع)
EXPOSE 9210

# 7. دستور اجرای نهایی (با نام فایل صحیح)
CMD ["python3", "storcli_exporter.py"]
