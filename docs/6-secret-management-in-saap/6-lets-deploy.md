# Lets deploy our application 

In this section, we will deploy the `Nordmart Review UI` Application. `Nordmart Review UI` is a light weight application for management of product reviews. This application also requires backend `Nordmart Review` which is already deployed in your Tenant. This application implements review functionality for the products; it provides CRUDS API for reviews.

1. Open terminal on your DevSpace by pressing `` Ctrl+Shift+` `` or clicking `Options > Terminal > New Terminal` as highlighted below.

    --Add Image--

1. You can view the application by Logging In to the cluster & opening `<TENANT_NAME>-dev` project from projects.

    --Add Image--

2. Navigate to routes and copy the route. 

    --Add Image--

    Alternatively, you can run the following command in your devspace terminal. 

        REVIEW_API=$(oc get route review --template='{{ .spec.host }}' -n <TENANT>-dev)

3. Make a curl request on the url copied in the previous step. You should recieve a similar response as below.

    --Add Image--


Great Now that we know our `Nordmart Review` backend is working, lets deploy the `Nordmart Review UI`

## Deploy Nordmart Review UI

1. Open terminal on your DevSpace by pressing `` Ctrl+Shift+` `` or clicking `Options > Terminal > New Terminal` as highlighted below.

    --Add Image--

2. Make you are in `/projects/stakater-nordmart-review-ui` by running `pwd` 

    --Add Image--

3. Open the deploy/values.yaml in the editor and update the `application.deployment.env.REVIEW_API` value with the url you copied above.

    --Add Image--

    Alternatively, you can run the following command in your terminal, 
        
        yq -i -y --arg REVIEW_API "$REVIEW_API" '.application.deployment.env.REVIEW_API.value|=$REVIEW_API' deploy/values.yaml

4. Before we deploy the application, lets build dependencies of helm chart in deploy/ folder.

        helm dependency build deploy/

    --Add Image--


5. Lets deploy the application by running the following command. 

        helm template deploy/ | oc apply -f - -n <TENANT>-dev

    --Add Image--


## Guide user to their application (UI)

6. You can view the application by Logging In to the cluster & opening `<TENANT_NAME>-dev` project from projects.

    --Add Image--

7. Navigate to routes and copy route named `review-web` and open it in your browser. 

    --Add Image--

    Alternatively, you can run the following command in your devspace terminal and open it in your browser.

        REVIEW_UI=https://$(oc get route review-web --template='{{ .spec.host }}' -n <TENANT>-dev)/

        echo $REVIEW_UI

## 🖼️ Big Picture

Great Work, Now that we have deployed our application, we can move on to our main topic secrets management.

## 🔮 Learning Outcomes

