global class ProductBatchSchedular implements Schedulable 
{
  global void execute(SchedulableContext sc) 
  {
      ProductDiscontinuationEmailBatch pb = new ProductDiscontinuationEmailBatch(); 
      database.executebatch(pb);
  }
}