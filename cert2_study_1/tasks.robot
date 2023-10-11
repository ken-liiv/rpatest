*** Settings ***
Documentation       Playwright template robot - orders robots from test site according to input data.
...                 Add more lines of this kind of text with ...
...                 This is a new line

Library    RPA.Browser.Playwright
Library    RPA.HTTP
Library    RPA.Tables
Library    Dialogs
Library    RPA.Excel.Files
Library    RPA.PDF
Library    RPA.Archive
Library    OperatingSystem

*** Variables ***
${ORDERS_URL}    https://robotsparebinindustries.com/orders.csv
${RECEIPT_ELEMENT}    xpath=//*[@id="receipt"]
${RECEIPTS_DIRECTORY}    ${OUTPUT_DIR}${/}receipts
${MODAL_BUTTON}    

${orders}
${roboselfie}

*** Tasks ***
Work task
    ${orders}=     Download orders
    # Submit orders for every order row in downloaded orders
    FOR    ${order_row}    IN    @{orders}
        Log    ${order_row}
        Open robot order website
        Close the modal
        Fill the form    ${order_row}[Head]    ${order_row}[Body]    ${order_row}[Legs]    ${order_row}[Address]
        Save receipt as PDF and append robot image    ${order_row}[Order number]
        Close Page
        #BREAK
    END
    Create ZIP with receipts
    [Teardown]    Remove receipt pdf folder

*** Keywords ***
Open robot order website
    New Browser    headless=False
    #Open Browser
    New Page    https://robotsparebinindustries.com/#/robot-order

Download orders
    ${orders_table}=    RPA.HTTP.Download    ${ORDERS_URL}    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Close Workbook
    RETURN    ${orders}

Close the modal
    # Should check if modal is visible
    Click    xpath=//*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Click button and wait for it to disappear
    [Arguments]    ${selector}
    Click    ${selector}
    Wait For Elements State    ${selector}    detached    0.5s

Fill the form
    [Arguments]    ${head_option}    ${body_option}    ${legs_option}    ${address}
    # Select head
    Select Options By    xpath=//*[@id="head"]    value    ${head_option}
    # Select body
    Click   id=id-body-${body_option}
    # Select legs
    Fill Text    xpath=/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${legs_option}
    # Fill address
    Fill Text    xpath=//*[@id="address"]    ${address}
    # Click preview
    Click    xpath=//*[@id="preview"]
    Wait Until Keyword Succeeds    5x    0.3s    Click button and wait for it to disappear    xpath=//*[@id="order"]
    # Click order, check for "bug" modal & fix
    #Wait Until Keyword Succeeds    5x    2s    Click    xpath=//*[@id="order"]

Save receipt as PDF and append robot image
    [Arguments]    ${order_number}
    Wait For Elements State    ${RECEIPT_ELEMENT}    visible
    ${receipt_html}=    Get Property    ${RECEIPT_ELEMENT}    outerHTML
    Html To Pdf    ${receipt_html}    ${RECEIPTS_DIRECTORY}${/}${order_number}.pdf
    ${roboselfie}=    Take Screenshot    selector=#robot-preview-image
    ${files_to_append}=    Create List    ${roboselfie}
    Log    ${roboselfie}
    Add Files To Pdf    ${files_to_append}    ${RECEIPTS_DIRECTORY}${/}${order_number}.pdf    append=True 
    #Close Pdf

Create ZIP with receipts
    Archive Folder With Zip     ${RECEIPTS_DIRECTORY}    result.zip

Remove receipt pdf folder
    Remove Directory    ${RECEIPTS_DIRECTORY}    True