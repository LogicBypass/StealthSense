# StealthSense: The Ultimate Open-Source PC Surveillance Solution

  Keep your PC protected and secure with StealthSense, the open-source IP monitoring tool to never have to worry about theft and unauthorized "EvilTwin" attacks.

  StealthSense makes it simple to monitor your PC's IP address
  Upon start-up, the tool checks for any changes and informs you via email if necessary. 
  This ensures that your device is always secure and protected.

  With no user login required, your data is kept safe and encrypted. 
  This means that your information is protected from any potential threats.

  Written in plain code, StealthSense is easy to use, and understand.
  With its easy-to-edit code, you can have a functional and efficient tool without any bloatware.

  Enjoy peace of mind knowing that your device is always protected with StealthSense. Whether you're worried about theft or just want to keep an eye on your PC, this tool has got you covered.

---
## Instructions: 
<details>
  <summary>How to create Gmail SMPT Password</summary>
  
### How to create Gmail SMPT Password:
  - **Step #1** — [Accessing Google Account](https://accounts.google.com/servicelogin)
  
    Log in to your Google account with your login credentials
    
    <img src="https://user-images.githubusercontent.com/62214984/216173317-97d60a4f-fd84-4e21-95e8-65e0ec2fdac0.png" width=40% height=40%>
    
    </br>
  - **Step #2** — Enabling 2-Step Verification
  
    - Select **Security** from the left navigation bar    
    - Select **2-Step Verification** option, and complete the further setup.
    ![image](https://user-images.githubusercontent.com/62214984/216176288-204ac007-350f-4c61-afb0-2c785a143ca9.png)
    
  - **Step #3** — Generating App Password
    - Select [App Passwords](https://security.google.com/settings/security/apppasswords) (Under 2-Step Verification)
    ![image](https://user-images.githubusercontent.com/62214984/216177271-bb0bd704-a932-42c1-954d-217558ac8130.png)
    
    - Then, select the app from the drop-down choice and choose Other (Custom name).
    ![image](https://user-images.githubusercontent.com/62214984/216178025-638c2590-c28c-445c-a6d1-83d5236b1df3.png)
    
    - Give any name of your choice to your App password and hit Generate
    ![image](https://user-images.githubusercontent.com/62214984/216177830-5bfbf888-d979-4daa-a767-bb6063020822.png)
    
    - ### Once the app password is generated, you need to save it for later
    ![image](https://user-images.githubusercontent.com/62214984/216178686-67408f24-ef25-4e1c-9f18-eda702aac57d.png)
    </br>
  </br>
</br>

</details>

---
### `StealthSense.ps1` Configuration:
  - Open `StealthSense.ps1` in any text editor
  - Edit (line 8) `$PcName = "GiveMeAName"` Give a name to your PC
  - Edit (line 9) `$Gmail_Address = "Your_Gmail_Address"` Change to your Gmail accout that you're created SMTP password  
  - Edit (line 10) `$Password = "SMPT_Generated_Password"` Insert Generated App Password from previous section. 
  - Edit (line 33) `$ToUsers = "Mail_Addresses1", "Mail_Addresses2", "Mail_Addresses3";` Insert Emails where to send the alert 
    - For one address remove the rest placeholders 
      - Ex: 1 address `$ToUsers = "test@gmail.com";`
      - Ex: 2 addresses `$ToUsers = "test@gmail.com", "test2@gmail.com";`
      - And so on.. 
      
#### After Configuration, run `startup.cmd` and it will automaticaly add the script to "Task Scheduler" and generate 3 log files:
  - startup.log - For debuging
  - Log_IP.log - For history logging (this history will be sent to email)
  - ip.txt - Last IP Address
  
#### Email Example:
  ![image](https://user-images.githubusercontent.com/62214984/216189910-48626828-b606-40ab-b9a2-010c68bf5d36.png)
