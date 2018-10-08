# 01_hello_world

## Steps

1. Run the pre-req in 00_pre_req
2. Open the AWS console in your account.
3. Click 'Services' in the top tool bar, and type `lambda` and then click on `lambda`
4. Click the `Create Function` button
5. Steps on this page:
    1. Name the function `hello_world`
    2. Select the Python 3.6 Runtime
    3. Select "Chose and existing role"
    4. Select the `tf.hello_world.lambda.role`.
    5. Click Create Function
6. Welcome to the Cloud9 Editor/IDE. Scroll down to "edit code inline" and do the following:
    1. Copy the contents of `hello_world.py` into your copy buffer
    2. in the "lambda_function" tab, select-all the text.
    3. Paste the contents of `hello_world.py` over the existing content.
    4. Click "Save"
7. Make a test case:
    1. Click the "Test" button.  This will bring up a new pane where you can edit a JSON blob.
    2. The contents don't matter in this case, provided it's valid JSON.  So make something silly
    3. Set an "Event name" to something CamelCase.
    4. Click "create"
8. Run your test case!  Click "Test"
    1. Expand your results in the green or red modal above named "Execution result:"

## Cleanup:

Go to the lambda console, click your function's radio button, and click "Actions" -> "Delete"

Then in your shell, go back to 00_pre_req, and run `bash ./destroyer.sh`