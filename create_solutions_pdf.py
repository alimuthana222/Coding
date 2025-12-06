#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from reportlab.lib.pagesizes import letter, A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted, PageBreak
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.enums import TA_RIGHT, TA_LEFT, TA_CENTER
from arabic_reshaper import reshape
from bidi.algorithm import get_display

def create_pdf():
    """Create a PDF with Q2 and Q3 solutions from the mid exam"""
    
    # Create PDF
    pdf_filename = "Mid_Exam_Q2_Q3_Solutions.pdf"
    doc = SimpleDocTemplate(pdf_filename, pagesize=A4,
                           rightMargin=72, leftMargin=72,
                           topMargin=72, bottomMargin=18)
    
    # Container for the 'Flowable' objects
    elements = []
    
    # Define styles
    styles = getSampleStyleSheet()
    
    # Title style
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#1a1a1a'),
        spaceAfter=30,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    # Heading style
    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=colors.HexColor('#2c3e50'),
        spaceAfter=12,
        spaceBefore=12,
        fontName='Helvetica-Bold'
    )
    
    # Code style
    code_style = ParagraphStyle(
        'Code',
        parent=styles['Code'],
        fontSize=9,
        leftIndent=20,
        fontName='Courier',
        textColor=colors.HexColor('#2c3e50'),
        backColor=colors.HexColor('#f4f4f4'),
        borderColor=colors.HexColor('#ddd'),
        borderWidth=1,
        borderPadding=10,
        spaceAfter=12
    )
    
    # Normal text style
    normal_style = ParagraphStyle(
        'CustomNormal',
        parent=styles['Normal'],
        fontSize=11,
        leading=16,
        spaceAfter=12,
        fontName='Helvetica'
    )
    
    # Add title
    elements.append(Paragraph("Mid Exam - Questions 2 & 3 Solutions", title_style))
    elements.append(Paragraph("حلول السؤال الثاني والثالث من امتحان المنتصف", title_style))
    elements.append(Spacer(1, 0.3*inch))
    
    # ==================== QUESTION 2 ====================
    elements.append(Paragraph("Question 2 (40 Marks)", heading_style))
    elements.append(Paragraph("السؤال الثاني (40 علامة)", heading_style))
    elements.append(Spacer(1, 0.2*inch))
    
    # Question text
    q2_text = """
    <b>Question:</b> Write a complete C# program which contains one dimensional array of 10 integer 
    numbers. Let the user insert the numbers through the keyboard. After entering the numbers 
    let the program count the occurrence of odd and even numbers in the array and display 
    the result on the screen by using foreach loop.
    """
    elements.append(Paragraph(q2_text, normal_style))
    
    q2_arabic = """
    <b>السؤال:</b> اكتب برنامج C# كامل يحتوي على مصفوفة أحادية البعد من 10 أرقام صحيحة. 
    دع المستخدم يُدخل الأرقام من خلال لوحة المفاتيح. بعد إدخال الأرقام، 
    دع البرنامج يعد تكرار الأرقام الفردية والزوجية في المصفوفة ويعرض 
    النتيجة على الشاشة باستخدام حلقة foreach.
    """
    elements.append(Paragraph(q2_arabic, normal_style))
    elements.append(Spacer(1, 0.2*inch))
    
    # Solution explanation
    elements.append(Paragraph("<b>Solution Explanation / شرح الحل:</b>", heading_style))
    
    explanation = """
    <b>Step-by-step approach (الخطوات):</b><br/>
    1. Create an integer array of size 10 (إنشاء مصفوفة من 10 عناصر)<br/>
    2. Use a for loop to get input from user (استخدام حلقة for لإدخال الأرقام)<br/>
    3. Initialize counters for odd and even numbers (تهيئة عدادات للأرقام الفردية والزوجية)<br/>
    4. Use foreach loop to iterate through array (استخدام حلقة foreach للمرور على المصفوفة)<br/>
    5. Check if number is odd or even using modulo operator (%) (فحص إذا كان الرقم فردي أو زوجي باستخدام %)<br/>
    6. Display the results (عرض النتائج)<br/>
    <br/>
    <b>Key Concepts (المفاهيم الأساسية):</b><br/>
    • A number is <b>even</b> if (number % 2 == 0) - الرقم زوجي إذا كان الباقي من القسمة على 2 يساوي صفر<br/>
    • A number is <b>odd</b> if (number % 2 != 0) - الرقم فردي إذا كان الباقي من القسمة على 2 لا يساوي صفر<br/>
    • <b>foreach</b> loop is used to iterate through collections - حلقة foreach تستخدم للمرور على المجموعات<br/>
    """
    elements.append(Paragraph(explanation, normal_style))
    elements.append(Spacer(1, 0.2*inch))
    
    # The C# code solution
    elements.append(Paragraph("<b>Complete C# Program:</b>", heading_style))
    
    csharp_code = """using System;

class Program
{
    static void Main()
    {
        // Step 1: Declare an array of 10 integers
        // الخطوة 1: تعريف مصفوفة من 10 أرقام صحيحة
        int[] numbers = new int[10];
        
        // Step 2: Get input from user
        // الخطوة 2: إدخال الأرقام من المستخدم
        Console.WriteLine("Please enter 10 integer numbers:");
        Console.WriteLine("من فضلك أدخل 10 أرقام صحيحة:");
        
        for (int i = 0; i < 10; i++)
        {
            Console.Write($"Enter number {i + 1}: ");
            numbers[i] = int.Parse(Console.ReadLine());
        }
        
        // Step 3: Initialize counters for odd and even numbers
        // الخطوة 3: تهيئة عدادات للأرقام الفردية والزوجية
        int evenCount = 0;  // Counter for even numbers - عداد الأرقام الزوجية
        int oddCount = 0;   // Counter for odd numbers - عداد الأرقام الفردية
        
        // Step 4: Use foreach loop to count odd and even numbers
        // الخطوة 4: استخدام حلقة foreach لعد الأرقام
        foreach (int number in numbers)
        {
            // Step 5: Check if number is even or odd
            // الخطوة 5: فحص إذا كان الرقم زوجي أو فردي
            if (number % 2 == 0)
            {
                evenCount++;  // Increment even counter - زيادة عداد الزوجي
            }
            else
            {
                oddCount++;   // Increment odd counter - زيادة عداد الفردي
            }
        }
        
        // Step 6: Display the results
        // الخطوة 6: عرض النتائج
        Console.WriteLine("\\n===== Results / النتائج =====");
        Console.WriteLine($"Number of Even numbers: {evenCount}");
        Console.WriteLine($"عدد الأرقام الزوجية: {evenCount}");
        Console.WriteLine($"Number of Odd numbers: {oddCount}");
        Console.WriteLine($"عدد الأرقام الفردية: {oddCount}");
        
        Console.ReadKey();
    }
}"""
    
    # Add code with proper formatting
    code_lines = csharp_code.split('\n')
    for line in code_lines:
        elements.append(Preformatted(line, code_style))
    
    elements.append(Spacer(1, 0.2*inch))
    
    # Example output
    elements.append(Paragraph("<b>Example Output / مثال على الإخراج:</b>", heading_style))
    example_output = """Please enter 10 integer numbers:
من فضلك أدخل 10 أرقام صحيحة:
Enter number 1: 5
Enter number 2: 8
Enter number 3: 12
Enter number 4: 7
Enter number 5: 20
Enter number 6: 15
Enter number 7: 3
Enter number 8: 10
Enter number 9: 9
Enter number 10: 14

===== Results / النتائج =====
Number of Even numbers: 5
عدد الأرقام الزوجية: 5
Number of Odd numbers: 5
عدد الأرقام الفردية: 5"""
    
    for line in example_output.split('\n'):
        elements.append(Preformatted(line, code_style))
    
    # Page break before Q3
    elements.append(PageBreak())
    
    # ==================== QUESTION 3 ====================
    elements.append(Paragraph("Question 3 (Part 3) (20 Marks)", heading_style))
    elements.append(Paragraph("السؤال الثالث (الجزء الثالث) (20 علامة)", heading_style))
    elements.append(Spacer(1, 0.2*inch))
    
    # Question text
    q3_text = """
    <b>Question:</b> What is the output on screen of the following code?
    """
    elements.append(Paragraph(q3_text, normal_style))
    
    q3_arabic = """
    <b>السؤال:</b> ما هو الإخراج على الشاشة للكود التالي؟
    """
    elements.append(Paragraph(q3_arabic, normal_style))
    elements.append(Spacer(1, 0.1*inch))
    
    # The code to analyze
    q3_code = """for (int i = 0; i < 10; i++)
{
    if (i == 2 || i == 6)  { continue; }
    if (i == 4 && i == 8)  { break;    }
    Console.Write(i);
}"""
    
    for line in q3_code.split('\n'):
        elements.append(Preformatted(line, code_style))
    
    elements.append(Spacer(1, 0.2*inch))
    
    # Solution explanation
    elements.append(Paragraph("<b>Solution Explanation / شرح الحل:</b>", heading_style))
    
    q3_explanation = """
    Let's trace through the code step by step:<br/>
    دعنا نتتبع الكود خطوة بخطوة:<br/>
    <br/>
    <b>Understanding the keywords / فهم الكلمات المفتاحية:</b><br/>
    • <b>continue</b>: Skip the rest of the current iteration and go to next iteration<br/>
      تخطي بقية التكرار الحالي والانتقال للتكرار التالي<br/>
    • <b>break</b>: Exit the loop completely<br/>
      الخروج من الحلقة بشكل كامل<br/>
    <br/>
    <b>Step-by-step execution / التنفيذ خطوة بخطوة:</b><br/>
    • i = 0: No conditions met, print 0 → Output: <b>0</b><br/>
    • i = 1: No conditions met, print 1 → Output: <b>01</b><br/>
    • i = 2: First condition (i == 2) is TRUE, <b>continue</b> → Skip printing, Output: <b>01</b><br/>
    • i = 3: No conditions met, print 3 → Output: <b>013</b><br/>
    • i = 4: First condition FALSE (4 ≠ 2 and 4 ≠ 6), Second condition FALSE (4 == 4 but 4 ≠ 8, so 4 == 4 && 4 == 8 is FALSE), print 4 → Output: <b>0134</b><br/>
    • i = 5: No conditions met, print 5 → Output: <b>01345</b><br/>
    • i = 6: First condition (i == 6) is TRUE, <b>continue</b> → Skip printing, Output: <b>01345</b><br/>
    • i = 7: No conditions met, print 7 → Output: <b>013457</b><br/>
    • i = 8: First condition FALSE (8 ≠ 2 and 8 ≠ 6), Second condition FALSE (8 ≠ 4, so 8 == 4 && 8 == 8 is FALSE), print 8 → Output: <b>0134578</b><br/>
    • i = 9: No conditions met, print 9 → Output: <b>01345789</b><br/>
    <br/>
    <b>Important Note / ملاحظة مهمة:</b><br/>
    The second condition (i == 4 && i == 8) will NEVER be true because a variable cannot equal 4 AND 8 at the same time!<br/>
    الشرط الثاني (i == 4 && i == 8) لن يكون صحيحاً أبداً لأن المتغير لا يمكن أن يساوي 4 و 8 في نفس الوقت!<br/>
    So the <b>break</b> statement will never execute.<br/>
    لذلك جملة <b>break</b> لن تنفذ أبداً.
    """
    elements.append(Paragraph(q3_explanation, normal_style))
    elements.append(Spacer(1, 0.2*inch))
    
    # Final answer
    elements.append(Paragraph("<b>Final Answer / الإجابة النهائية:</b>", heading_style))
    answer_text = """
    The correct answer is: <b>c. 01345789</b><br/>
    <br/>
    الإجابة الصحيحة هي: <b>c. 01345789</b><br/>
    <br/>
    The program prints all numbers from 0 to 9, except 2 and 6 (which are skipped by continue).<br/>
    البرنامج يطبع جميع الأرقام من 0 إلى 9، ما عدا 2 و 6 (التي يتم تخطيها بواسطة continue).
    """
    elements.append(Paragraph(answer_text, normal_style))
    
    # Add footer
    elements.append(Spacer(1, 0.5*inch))
    footer_text = """
    <i>Note: This solution is designed to be beginner-friendly with detailed explanations in both English and Arabic.</i><br/>
    <i>ملاحظة: هذا الحل مصمم ليكون مناسباً للمبتدئين مع شروحات تفصيلية بالإنجليزية والعربية.</i>
    """
    elements.append(Paragraph(footer_text, normal_style))
    
    # Build PDF
    doc.build(elements)
    print(f"PDF created successfully: {pdf_filename}")
    return pdf_filename

if __name__ == "__main__":
    create_pdf()
