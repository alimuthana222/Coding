# Mid Exam Solutions - Questions 2 & 3
## حلول امتحان المنتصف - السؤال الثاني والثالث

This repository contains the solutions for Questions 2 and 3 from the mid exam.

هذا المستودع يحتوي على حلول للسؤال الثاني والثالث من امتحان المنتصف.

---

## 📄 Files / الملفات

### Main Solution Document / المستند الرئيسي
- **Mid_Exam_Q2_Q3_Solutions.pdf** - Complete PDF with questions and detailed solutions in both English and Arabic
  - ملف PDF كامل يحتوي على الأسئلة والحلول التفصيلية بالإنجليزية والعربية

### C# Source Code Files / ملفات الكود
- **Q2_Solution.cs** - Complete C# program for Question 2 (Array with odd/even counter)
  - برنامج C# كامل للسؤال الثاني (مصفوفة مع عداد الأرقام الفردية والزوجية)
  
- **Q3_Solution.cs** - C# program demonstrating Question 3 (continue/break statements)
  - برنامج C# يوضح السؤال الثالث (جمل continue/break)

### Utility Script / سكريبت مساعد
- **create_solutions_pdf.py** - Python script used to generate the PDF document
  - سكريبت Python المستخدم لإنشاء ملف PDF

---

## 📝 Question 2 Summary / ملخص السؤال الثاني

**Task:** Write a C# program with a 10-element integer array that counts odd and even numbers using a foreach loop.

**المهمة:** كتابة برنامج C# يحتوي على مصفوفة من 10 عناصر ويعد الأرقام الفردية والزوجية باستخدام حلقة foreach.

**Key Concepts / المفاهيم الأساسية:**
- Arrays / المصفوفات
- User input / إدخال المستخدم
- foreach loop / حلقة foreach
- Modulo operator (%) / معامل الباقي
- Conditional statements / الجمل الشرطية

**Example Output:**
```
Number of Even numbers: 5
Number of Odd numbers: 5
```

---

## 📝 Question 3 Summary / ملخص السؤال الثالث

**Task:** Determine the output of code using continue and break statements.

**المهمة:** تحديد الإخراج لكود يستخدم جمل continue و break.

**The Code:**
```csharp
for (int i = 0; i < 10; i++)
{
    if (i == 2 || i == 6)  { continue; }
    if (i == 4 && i == 8)  { break;    }
    Console.Write(i);
}
```

**Answer / الإجابة:** `01345789`

**Explanation / الشرح:**
- Numbers 2 and 6 are skipped by `continue`
- الأرقام 2 و 6 يتم تخطيها بواسطة `continue`
- The `break` statement never executes (impossible condition)
- جملة `break` لن تنفذ أبداً (شرط مستحيل)

---

## 🚀 How to Run the C# Programs / كيفية تشغيل برامج C#

### For Question 2:
```bash
dotnet new console -n Q2
cp Q2_Solution.cs Q2/Program.cs
cd Q2
dotnet run
```

### For Question 3:
```bash
dotnet new console -n Q3
cp Q3_Solution.cs Q3/Program.cs
cd Q3
dotnet run
```

Or use any C# IDE like Visual Studio, Visual Studio Code, or Rider.

أو استخدم أي IDE لـ C# مثل Visual Studio، Visual Studio Code، أو Rider.

---

## 📚 Learning Resources / مصادر التعلم

### For Arrays and Loops / للمصفوفات والحلقات:
- Microsoft C# Documentation: https://docs.microsoft.com/en-us/dotnet/csharp/
- C# foreach statement
- C# continue and break statements

### للمبتدئين / For Beginners:
- The solutions are designed to be beginner-friendly
- الحلول مصممة لتكون مناسبة للمبتدئين
- Each step is clearly commented in both English and Arabic
- كل خطوة مشروحة بوضوح بالإنجليزية والعربية

---

## ✅ Verification / التحقق

Both solutions have been tested and verified to work correctly:
- Q2: Successfully counts odd and even numbers
- Q3: Produces output `01345789` as expected

كلا الحلين تم اختبارهما والتحقق من صحتهما:
- السؤال 2: يعد الأرقام الفردية والزوجية بنجاح
- السؤال 3: ينتج الإخراج `01345789` كما هو متوقع

---

## 📞 Contact / التواصل

If you have any questions about these solutions, please feel free to open an issue.

إذا كان لديك أي أسئلة حول هذه الحلول، لا تتردد في فتح issue.

---

**Good luck with your studies! 🎓**  
**حظاً موفقاً في دراستك! 🎓**
