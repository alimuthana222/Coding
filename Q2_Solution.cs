using System;

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
        Console.WriteLine("\n===== Results / النتائج =====");
        Console.WriteLine($"Number of Even numbers: {evenCount}");
        Console.WriteLine($"عدد الأرقام الزوجية: {evenCount}");
        Console.WriteLine($"Number of Odd numbers: {oddCount}");
        Console.WriteLine($"عدد الأرقام الفردية: {oddCount}");
        
        Console.ReadKey();
    }
}
