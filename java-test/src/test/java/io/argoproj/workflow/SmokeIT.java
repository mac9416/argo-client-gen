package io.argoproj.workflow;

import io.argoproj.workflow.models.Template;
import io.argoproj.workflow.models.Workflow;
import io.argoproj.workflow.models.WorkflowSpec;
import io.kubernetes.client.models.V1Container;
import io.kubernetes.client.models.V1ObjectMeta;
import java.util.ArrayList;
import java.util.Collections;
import org.junit.Test;

public class SmokeIT {

  private final Workflow wf =
      new Workflow()
          .metadata(new V1ObjectMeta().generateName("hello-world-").namespace("argo"))
          .spec(
              new WorkflowSpec()
                  .entrypoint("whalesay")
                  .templates(new ArrayList<>())
                  .addTemplatesItem(
                      new Template()
                          .name("whalesay")
                          .container(
                              new V1Container()
                                  .image("cowsay:v1")
                                  .command(Collections.singletonList("cowsay"))
                                  .args(Collections.singletonList("hello world")))));

  @Test
  public void testKubeAPI() throws Exception {
    //    Workflow created = new KubeAPI().createWorkflow(wf);
    //    assertNotNull(created.getMetadata());
    //    assertNotNull(created.getMetadata().getUid());
  }

  @Test
  public void testArgoServerAPI() throws Exception {
    new ArgoServerAPI().listWorkflows();
    //    Workflow created = new ArgoServerAPI().createWorkflow(wf);
    //    assertNotNull(created.getMetadata());
    //    assertNotNull(created.getMetadata().getUid());
  }
}
