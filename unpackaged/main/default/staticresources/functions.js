
// Indicates which PG credit data in the credit review object we will refresh from credit pulls. Initially all set to false
var PGCredit_toRefresh = {
    'PG1_EXP' : false, 
    'PG1_EQF' : false, 
    'PG2_EXP' : false, 
    'PG2_EQF' : false, 
    'PG3_EXP' : false, 
    'PG3_EQF' : false
};
var bankChanges = false;
var isMonitoringRun=true;
var isBusinessMonitoringRun = {'experian' : true, 'equifax' : true} ; // Keeps track of whether business credit pulling is being monitored for each bureau
var intervalID_EXP, intervalID_EQF, childWindow;
var bizMonitorIntervalID = {'experian' : 0, 'equifax' : 0}; // Ids of the business monitoring polling intervals for each bureau
var start1MinuteTimer = false;
var stopReload = false;
function monthDiff(start, end) {
    var tempDate = new Date(start);
    var monthCount = 0;
    while((tempDate.getMonth()+''+tempDate.getFullYear()) != (end.getMonth()+''+end.getFullYear())) {
        monthCount++;
        tempDate.setMonth(tempDate.getMonth()+1);
    }
    return monthCount+1;
}
// Currency Format
function currencyFormat(n, currency) {
    return currency + "" + n.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,");
}
//monthDiff(new Date(2015, 7, 5), new Date())
//============================= Fill Key Business Guarantors ==========================
function getGuarantorInfo(){  
      Visualforce.remoting.Manager.invokeAction(
       'CreditreViewScreenController.getGuarantorInformation', 
           parentId,
           function(result, event) {
            result.flag1 = '';
            result.flag2 = '';
            result.flag3 = '';
            var div ='';
            if(result.pg1 !== undefined){
              $('#signor-ssn').removeAttr('disabled');
              if (result["ssn_search"]["checked"]["PG1"]) {
                $('#signor-ssn').find('i').show();
              } else {
                $('#signor-ssn').find('i').hide();
              }

                div +='<div class="col-md-4">'; 
                div +='<div class="form-group">'; 
                  div +='<label class="col-md-4 control-label" for="textinput">Signor</label>'; 
                  div +='<div class="col-md-8">'; 
                    div +='<p>'+result.pg1+'</p>'; 
                  div +='</div>'; 
                div +='</div>'; 
              div +='</div>'; 
              $('.pg1_section').show();
              $('.pg1_header').text(result.pg1+' (Signor)');

              
              if(result.flag1 != ''){
                  var title = $('<div></div>').html(result.flag1).text();
          var str_esc=escape(title);
                  $('.equifax1_error,.experian1_error').show().find('.error_area').html(unescape(str_esc));
                  $('.pullSection1 .title').text(result.pg1+' (Signor)').attr('data-id',$('#signor-contact_id').val());
                $('.equifax1,.experian1').hide();
                $('.pull1').attr('disabled',true);
                
              }else{
                  $('.equifax1_error,.experian1_error').hide();
                  $('.pullSection1 .title').text(result.pg1+' (Signor)').attr('data-id',$('#signor-contact_id').val());
                $('.equifax1,.experian1,pullSection1').show();
                $('.pull1').removeAttr('disabled');
              }
            }else{
              $('.equifax1_error,.experian1_error,pullSection1').hide();
              $('.equifax1,.experian1').show();
              $('.pg1_section').hide();
       }
       if(result.pg2 !== undefined){
              $('#gua2-ssn').removeAttr('disabled');
              if (result["ssn_search"]["checked"]["PG2"]) {
                $('#gua2-ssn').find('i').show();
              } else {
                $('#gua2-ssn').find('i').hide();
              }

              div +='<div class="col-md-4">';  
                div +='<div class="form-group">'; 
                  div +='<label class="col-md-4 control-label" style="padding-right: 0;" for="textinput">Guarantor #2</label>'; 
                  div +='<div class="col-md-8">'; 
                    div +='<p>'+result.pg2+'</p>'; 
                  div +='</div>'; 
                div +='</div>'; 
              div +='</div>'; 
              $('.pg2_section').show();
              $('.pg2_header').text(result.pg2+' (Guarantor #2)');

              if(result.flag2 != ''){
                  var title = $('<div></div>').html(result.flag2).text();
          var str_esc=escape(title);
                  $('.equifax2_error,.experian2_error').show();
                  $('.pullSection2 .title').text(result.pg2+' (Guarantor #2)').attr('data-id',$('#guarantor2-contact_id').val());
                  $('.equifax2_error').children().find('.error_area').html(unescape(str_esc));
                  $('.experian2_error').children().find('.error_area').html(unescape(str_esc));
                $('.equifax2,.experian2').hide();
                $('.pull2').attr('disabled',true);

              }else{
                  $('.equifax2_error,.experian2_error').hide();
                  $('.pullSection2 .title').text(result.pg2+' (Guarantor #2)').attr('data-id',$('#guarantor2-contact_id').val());
                $('.equifax2,.experian2,pullSection2').show();
                $('.pull2').removeAttr('disabled');
              }
            }else{
              $('.equifax2_error,.experian2_error,.pullSection2').hide();
              $('.equifax2,.experian2').show();
              $('.pg2_section').hide();

            }if(result.pg3 !== undefined){
              $('#gua3-ssn').removeAttr('disabled');
              
              if (result["ssn_search"]["checked"]["PG3"]) {
                $('#gua3-ssn').find('i').show();
              } else {
                $('#gua3-ssn').find('i').hide();
              }

              div +='<div class="col-md-4"> '; 
                div +='<div class="form-group">'; 
                  div +='<label class="col-md-4 control-label" style="padding-right: 0;" for="textinput">Guarantor #3</label>'; 
                  div +='<div class="col-md-8">'; 
                    div +='<p>'+result.pg3+'</p>'; 
                  div +='</div>'; 
                div +='</div>'; 
              div +='</div>'; 
              $('.pg3_section').show();
              $('.pg3_header').text(result.pg3+' (Guarantor #3)');
              if(result.flag3 !=''){
                  var title = $('<div></div>').html(result.flag3).text();
          var str_esc=escape(title);
                  $('.equifax3_error,.experian3_error').show().find('.error_area').html(unescape(str_esc));
                  $('.pullSection3 .title').text(result.pg3+' (Guarantor #3)').attr('data-id',$('#guarantor3-contact_id').val());
                $('.equifax3,.experian3').hide();
                $('.pull3').attr('disabled',true);
              }else{
                  $('.equifax3_error,.experian3_error').hide();
                  $('.pullSection3 .title').text(result.pg3+' (Guarantor #3)').attr('data-id',$('#guarantor3-contact_id').val());
                $('.equifax3,.experian3,.pullSection3').show();
                $('.pull3').removeAttr('disabled');
              }
            }else{
              $('.equifax3_error,.experian3_error,.pullSection3').hide();
              $('.equifax3,.experian3').show();
              $('.pg3_section').hide();
        }
        if(div ==''){
          div='<p align="center">No Guarantors Selected</p>';
        }
              $('.gaurantors_info').html(div);
              setTimeout(function(){
               // reloadGuarantorPull();
              },100)
           },{escape:true}
       )
  }
// ======================== Delete Related Contact ==============================================
function removeRelatedContact(conId){
  conId = $(conId).attr('data-id');
  var r = confirm("This will remove the contact from this credit review. Are you sure?");
  if (r == true) {
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.relatedContactDelete',
      conId,
      function(result,event){
        callAssociatedContacts();// Reload Associated Contact Records
        $('#processing').modal('hide');
        setTimeout(function(){reloadGuarantorPull();},100)
      }
        )
  }
}
// ================================== Delete Related Business =================================
function removeRelatedBusiness(obj){
  var accId = $(obj).attr('data-id');
  var name = $(obj).attr('data-name');
  var r = confirm("Are you sure you want to remove "+name+" from the related businesses list?");
  if (r == true) {
     $('#processing').modal('show');
     Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.relatedBusinessDelete',
    accId,
    function(result,event){
      getOtherRelatedBusinessesRecord();// Reload Other Related Business Records
      $('#processing').modal('hide');
    }
    
    )
  }
  
}
//============================== Fetch Attachment And Notes====================================
function fetchNotesAndAttachments(){
  Visualforce.remoting.Manager.invokeAction(
     fetchAttachmentAndNote, 
     parentId,
     function(result, event) {
      if(result.length > 0){
        var table='<div style="overflow-y: scroll; max-height: 300px;"><table class="table table-striped table-bordered" style="margin-bottom:0px">';
         table +='<thead><tr><th>Type</th><th>Title</th><th>Created By</th><th width="200">Created Date</th><th>Action</th></tr><thead>';
         table +='<tbody>';
        for(var index=0;index < result.length; index++){  
            var dateTime = stringToDateTime(result[index].CreatedDate); 
          var StringDateTime = timeConverter(dateTime); 
          var link = result[index].Id.startsWith('00P') ? '/servlet/servlet.FileDownload?file='+result[index].Id : '/'+result[index].Id;
          table +='<tr><td>'+result[index].Type+'</td><td><a target="_blank" href="'+link+'">'+result[index].Title+'</a></td><td>'+result[index].UserName+'</td><td>'+StringDateTime+'</td><td><a href="javascript:void(0)" onclick="removeAttchNotes(\''+result[index].Type+'\',\''+result[index].Id+'\')">remove</a></td></tr>';
        }
        table +='</tbody>';
        table +='</table></div>';
        $('.noteAttachmentBox').html(table);
       
      }else{
         $('.noteAttachmentBox').html('<div style="height: 100px;line-height: 100px;text-align: center;"><span>No Record</span></div>');
      }
        $('#attachment-count').text(result.length);
     }     
   ); 
}
function removeAttchNotes(objType,id){
  var r = confirm('Are you Sure!');
  if(r){
    Visualforce.remoting.Manager.invokeAction(
     'CreditreViewScreenController.deleteFile', 
         objType,
         id,
         parentId,
         function(result, event) {
          if (event.status) {
                  fetchNotesAndAttachments();
              } else if (event.type === 'exception') {
                alert(event.message);
              } else {
                alert(event.message);
              }
         },{escape:true}     
     );
  }else{

  }
  
}
//==================================== Saving Note================================================
function saveNotes(){
  var subject = $('#notes-subject').val();
  var notes = $('#notes-body').val();
  Visualforce.remoting.Manager.invokeAction(
     saveNote, 
     subject,
     notes,
     parentId,
     function(result, event) {
      if (event.status) {
                if(result != ''){
          $('#notes-subject').val('');
            $('#notes-body').val('');
          $('#notesmodel').modal('hide');
          //$('.modal-backdrop').remove();
          fetchNotesAndAttachments(parentId);
        }
            } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
    }     
   ); 
}
//=================================== Date Time Uility Start =======================
function stringToDateTime(stringDatetime){
  var reggie = /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/;
  var dateArray = reggie.exec(stringDatetime);
  var dateObject = new Date(
     (+dateArray[1]),
     (+dateArray[2])-1,
     (+dateArray[3]),
     (+dateArray[4]),
     (+dateArray[5]),
     (+dateArray[6])
  );                            
  return dateObject;
}
function formatAMPM(date) {
  var hours = date.getHours();
  var minutes = date.getMinutes();
  var ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours ? hours : 12; // the hour '0' should be '12'
  minutes = minutes < 10 ? '0'+minutes : minutes;
  var strTime = hours + ':' + minutes + ' ' + ampm;
  return strTime;
}
function formatedDate(dateObj){
  var dateObject;
  var year1 = dateObj.getFullYear();
  var month1 = (1 + dateObj.getMonth()).toString();
  month1 = month1.length > 1 ? month1 : month1;
  var day1 = dateObj.getDate().toString();
  day1 = day1.length > 1 ? day1 : day1;          
    dateObject = month1 + '/' + day1 + '/' + year1;
  return dateObject;
}
//=================================== Date Time Uility End =======================

//======================================== Drag Attachment Start =================================
var files='';
$(document).ready(function(e) {
    var dropbox; 
    var dropbox1;  
    
  dropbox = document.getElementById("dropbox");  
  dropbox.addEventListener("dragenter", dragenter, false);  
  dropbox.addEventListener("dragleave", dragleave, false);  
  dropbox.addEventListener("dragover", dragover, false);  
  dropbox.addEventListener("drop", drop, false); 
  
  dropbox1 = document.getElementById("dropbox1");  
  dropbox1.addEventListener("dragenter", dragenter, false);  
  dropbox1.addEventListener("dragleave", dragleave, false);  
  dropbox1.addEventListener("dragover", dragover, false);  
  dropbox1.addEventListener("drop", drop, false);  
  
  function defaults(e){
       e.stopPropagation();  
       e.preventDefault();  
  }
    function dragenter(e) {  
     $(this).addClass("active");
     defaults(e);
  }  
      
    function dragover(e) { 
     defaults(e);
    }  
    function dragleave(e) {  
     $(this).removeClass("active");
     defaults(e);
    }  

    function drop(e) {  
     $(this).removeClass("active");
     defaults(e);
      
     // dataTransfer -> which holds information about the user interaction, including what files (if any) the user dropped on the element to which the event is bound.
     //console.log(e);
       var dt = e.dataTransfer;  
       files = dt.files; 
     
     var file = files[0];
     
     if(unLockPermissionDeny)
      fileSelected(files);
    } 
});
//=================================== Drag Attachment End ==============================================

//============================= Add Attachment Start================================================
function fileSelected(inputfiles) {
  var file = inputfiles[0];
  files=inputfiles;
  var size = parseInt(file.size / 1024);
  //var info = '<div class="preview active-win"><div class="progress-holder"><span id="progress"></span></div><span class="percents"></span>';

    $(".upload-progress").show(500);
    //$("#progress").css("width","5%");
  //$(".percents").html("5%");
    $('#attachmentmodel').modal('show');
    $('#dropbox').css('background','rgb(15, 67, 118)');
    setTimeout(uploadFile,1000)
   
}
var progressInterval = null;
function uploadDocument(filename, filecontent) {
  var attachment         = new sforce.SObject('Attachment');
  attachment.Name        = filename;
  attachment.IsPrivate   = false;
  attachment.Body        = filecontent;
  attachment.ParentId    = parentId;
  var results = sforce.connection.create([attachment]);
  var flag = false;
  for (var i = 0; i < results.length; i++) {
    if (results[i].getBoolean("success")) {
      $('[id$=loading]').hide();
      $(".upload-progress").hide();
      //clearInterval(progressInterval);
      $('#btn').prop("disabled", false);
      flag = true;
    }
    else {
      $('[id$=loading]').hide();
      $('#fmsg').show();
    }
  }
  if(flag){
    $('#fileToUpload').val('');
    $('#attachmentmodel').modal('hide');
    fetchNotesAndAttachments(parentId);
    $(".upload-progress").hide(); 
  }
}
function uploadFile() {
  var file = files != ''?files:document.getElementById('fileToUpload').files;
  $('[id$=loading]').show();
  $('#btn').prop("disabled", true);
  for (var i = 0, f; f = file[i]; i++) {
        var reader = new FileReader();
    reader.onload = loaded;
    reader.fileName = f.name;
    reader.onerror = errorHandler;
    reader.readAsDataURL(f)
    }
        
}

function loaded(evt) {
  //alert(JSON.stringify(evt.target))
  //alert(evt.target.fileName)
  var filename = files != ''?files[0].name:document.getElementById('fileToUpload').files[0].name;
  var fileContent = String(evt.target.result);
  fileContent = fileContent.substr(fileContent.indexOf(',') + 1);
  uploadDocument(evt.target.fileName, fileContent);  
}

function errorHandler(evt) {
  if (evt.target.error.name == 'NotReadableError') {
    alert('File could not be read');
  }
  else {
    alert(evt.target.error);
  }
}
function timeConverter(UNIX_timestamp){
  var a = new Date(UNIX_timestamp);
  return a.toLocaleString();
  var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var year = a.getFullYear();
  var month = ("0" + (a.getMonth() + 1)).slice(-2);//months[a.getMonth()];
  var date = ("0" + a.getDate()).slice(-2);
  var hour = a.getHours();
  var min = ("0" + a.getMinutes()).slice(-2);
  var sec = ("0" + a.getSeconds()).slice(-2);
  var time = year+ '-' + month + '-' + date + ' ' + hour + ':' + min + ':' + sec ;
  return time;
}
function DateConverter(UNIX_timestamp){
  var a = new Date(UNIX_timestamp);
  var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var year = a.getFullYear();
  var month = months[a.getMonth()];
  var date = a.getDate();
  var hour = a.getHours();
  var min = a.getMinutes();
  var sec = a.getSeconds();
  var time = date+ ' ' + month + ' ' + year ;
  return time;
}
function DateConverterDatpicker(UNIX_timestamp){
  var a = new Date(UNIX_timestamp);
  var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var year = a.getFullYear();
  var month = ("0" + (a.getMonth() + 1)).slice(-2);
  var date = a.getDate();
  var hour = a.getHours();
  var min = a.getMinutes();
  var sec = a.getSeconds();
  var time = month + '/' + date+ '/' + year ;
  return time;
}
var formatDate = (function () {
  function addZero(num) {
      return (num >= 0 && num < 10) ? "0" + num : num + "";
  }

  return function (dt, withTime) {
      var formatted = '';
      
      if (dt) {
          formatted = [addZero(dt.getMonth() + 1), addZero(dt.getDate()), dt.getFullYear()].join("/");
          if (withTime) {
              var hours24 = dt.getHours();
              var hours = ((hours24 + 11) % 12) + 1;
              formatted = [formatted, [addZero(hours), addZero(dt.getMinutes())].join(":"), hours24 > 11 ? "pm" : "am"].join(" ");
          }
      }
      return formatted;
  }
})();
//===============================Add Attachment End=============================================
// Business Opportunity Records
function callBusinessOpp(obj){
  var accId = $(obj).attr('data-value');
  var datevalue = $(obj).closest('tr').find('td:eq(2)').text();
  Visualforce.remoting.Manager.invokeAction(
  'CreditreViewScreenController.getBusinessOpportunities', 
  parentId,
  accId,
  function(result, event) {
    if(result.length > 0 ){
      var table ='';
      table +='<table class="table table-striped table-bordered table-hover">';
            table +='<thead>';
              table +='<tr>';
                table +='<th> Name </th>';
                table +='<th> WC Exposure </th>';
                table +='<th> WC Last Fund Date </th>';
                table +='<th> Stage </th>';
              table +='</tr>';
            table +='</thead>';
            table +='<tbody>';
            for(var i =0 ; i<result.length;i++){
              var stage = result[i].StageName !== undefined?result[i].StageName:'N/A';
              var wcEx = result[i].Account.NF_WC_Exposure__c !== undefined?result[i].Account.NF_WC_Exposure__c:'N/A';
              var wcFu = result[i].Account.Newest_WC_Oppty_Funded__c !== undefined ? timeConverter(result[i].Account.Newest_WC_Oppty_Funded__c):'N/A';
              table +='<tr>';
                table +='<td> <a href="/'+result[i].Id+'" target="_blank" >'+result[i].Name+'</a></td>';
                table +='<td>'+wcEx+'</td>';
                table +='<td> '+datevalue+'</td>';
                table +='<td>'+stage+'</td>';
              table +='</tr>';
            }
            table +='</tbody>';
          table +='</table>';
        }
        $('#oppModal').html(table);
  }
  )
}
// ==========================Call Business Tag Other Related Business Record====================== 
function getOtherRelatedBusinessesRecord(){
  Visualforce.remoting.Manager.invokeAction(
  'CreditreViewScreenController.otherRelatedBusinesses', 
  parentId,
  function(result, event) {
  if(result.length > 0){
      var table ='<table class="table table-striped table-bordered table-hover">';
      table +='<thead>';
        table +='<tr>';
          table +='<th> Name </th>';
          table +='<th> WC Exposure </th>';
          table +='<th class=""> WC Last Fund Date </th>';
          table +='<th class=""> Action </th>';
        table +='</tr>';
      table +='</thead>';
       table +='<tbody>';
      for(var i=0; i < result.length; i++){
        var title = $('<div></div>').html(result[i]).text();
      var str_esc=escape(title);
           table +=unescape(str_esc);
          }
       table +='</tbody>';
    table +='</table>';
  $('#other-business-box').html(table);
  }else{
      $('#other-business-box').html('<br/><center>No Record</center>');
  }
  },{escape:true}     
  ); 
}
// Call Guarantor Tab Associated Contacts
function callAssociatedContacts(){
Visualforce.remoting.Manager.invokeAction(
 'CreditreViewScreenController.getAssociatedContacts', 
     parentId,
     function(result, event) {
       var table='';
       if(result != ''){
          var title = $('<div></div>').html(result).text();
      var str_esc=escape(title);
      var table='<table class="table table-striped table-bordered table-hover" id="sample_7">';
            table+='<thead>';
             table+='<tr>';
               table+='<th> Name </th>';
               table+='<th> Title </th>';
               table+='<th class="hidden-xs"> Account </th>';
               table+='<th class="hidden-xs"> Action </th>';
             table+='</tr>';
           table+='</thead>';
           table+='<tbody>'+unescape(str_esc);
             
           table+='</tbody>';
         table+='</table>';
          $('#associatedContacts').html(table);
          
       }else{
        $('#associatedContacts').html('<center>No Record</center>');
       }
     },{escape:true}     
 ); 
}
function saveFunctionCall(){
  $('#processing').modal('show');
  var conIds ='';
  var accIds ='';
  var coma='';
  var coma1='';
  $('.business_contact_checkbox').each(function(index, element) {
    if($(this).is(':checked')){
           conIds +=coma+$(this).val();
           coma=',';
        } 
  });
  $('.business_parent-checkbox').each(function(index, element) {
    if($(this).is(':checked')){
          accIds +=coma1+$(this).val();
          coma1=',';
        } 
  });
  saveBusiness(accIds,conIds);
  getOtherRelatedBusinessesRecord();// Reload Other Related Business Records
  callAssociatedContacts();// Reload Associated Contact Records
  reloadGuarantorPull();
  setTimeout(function(){$('#processing').modal('hide');},3000)
  

}
//===============================Save Business Search =====================================
function saveBusiness(accIds,conIds){
  Visualforce.remoting.Manager.invokeAction(
   'CreditreViewScreenController.saveBusinessRecord', 
       accIds,
       conIds,
       parentId,
       function(result, event) {
        if (event.status) {
                
            } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
       },{escape:true}     
   ); 
}
//========================== Reset Business Search Modal ========================================
function resetBusinessSearchModel(){
  $('#searchfield').val(accLegal_name);
  $('[id$=main-search]').show();
  $('.bottom-button1').show();
  $('.query').hide();
  $('.bottom-button2').hide();
  $('.error-tag').remove();
  $('.error-tag').next('br').remove();
}
//======================= Rebind Business Processing Window ============================
function rebindProcessingBox(){
  $('.searchvalue').text($('[id$=searchAgainTextBox]').val());
  $('[id$=main-search],.bottom-button2,.query').hide();
  $('[id$=search-process],.bottom-button1').show();
  setTimeout(function(){
        $('[id$=search-process],.bottom-button1').hide();
        $('.query,.bottom-button2').show();
        
    },2000);
}
//======================== Fetch Business Search Start ====================================
function callBussinessSearch(obj){         
if($(obj).val().length > 2){

    $(obj).next().remove('font');
    $(obj).next().remove('br');
    Visualforce.remoting.Manager.invokeAction(
         'CreditreViewScreenController.searchBusiness', 
         $(obj).val(),
         accountId,
         function(result, event) {
            if(result.length < 1){
                  $('#no-record').show(); 
                  $('#reloadBusiness').hide();
                  $('.business-result').html('');
              }else{
                  $('#reloadBusiness').show();
                  $('[id$=no-record]').hide(); 
                  var table='';
                  for(var index=0;index<result.length;index++){
                      table+='<tr>';
                      table+='<td class="ng-binding">';
                      table+='<div class="checker">';
                      table+='<span>';
                      table+='<input value="'+result[index].Id+'"  type="checkbox" class="ng-pristine ng-untouched ng-valid business_parent-checkbox" />';
                      table+='</span>';
                      table+='</div>';
                      table+=result[index].Name+' <a href="/'+result[index].Id+'"  target="_blank" class="showhidetrigger">(View Record)</a>';
                      table+='</td>';
                      if(result[index].Type !== undefined){
                        table+='<td><span class="badge ng-binding">'+result[index].Type+'</span></td>';
                      }else{
                        table+='<td> N/A</td>';
                      }
                      table+='</tr>'; 
                      if(result[index].Contacts  !== undefined){ 
                          table+='<tr style="display:none">';
                          table+='<td><input type="hidden" id="allBussiness_child_id'+result[index].Id+'" />';
                          table+='<table width="200" border="0" cellspacing="2" cellpadding="4" style="margin-left:15px;">';
                          table+='<tbody id="child-result'+result[index].Id+'" style="display:none">';
                          
                          for(var j=0;j<result[index].Contacts.length;j++){
                              table+='<tr>';
                              table+='<td width="21" align="center"><input  value="'+result[index].Contacts[j].Id+'" type="checkbox" class="business_contact_checkbox" />';
                              table+='<label for="checkbox"></label></td>';
                              table+='<td width="165" align="left">'+result[index].Contacts[j].Name+'</td>';
                              table+='</tr>';
                              
                              
                          } 
                          table+='<tr>';
                          table+='<td colspan="2">';
                          table+='<a style="margin-top:4px; display:block; text-decoration:underline;" href="javascript:void(0)" class="check-all">Select All</a>';
                          table+='</td>';
                          table+='</tr>';
                          table+='</tbody>';
                          table+='</table></td>';
                          table+='<td>&nbsp;</td>';
                          table+='</tr>';
                      }           
                  }
                  $('.business-result').html(table);
                  $('.business_parent-checkbox').click(function(){
                      if($(this).is(':checked')){
                          $('[id$=child-result'+$(this).val()+']').show();
                          $('[id$=child-result'+$(this).val()+']').closest('tr').show();
                          $('[id$=child-result'+$(this).val()+']').closest('tr').find('.business_contact_checkbox').prop("checked",true);
                      }else{
                          $('[id$=child-result'+$(this).val()+']').hide();
                          $('[id$=child-result'+$(this).val()+']').closest('tr').hide();
                          $('[id$=child-result'+$(this).val()+']').closest('tr').find('.business_contact_checkbox').prop("checked",false);
                      }
                  })
                  $('[class$=check-all]').click(function(){
                      $(this).closest('tbody').find('.business_contact_checkbox').each(function () {
                          var chk = $(this);
                          chk.prop("checked", !chk.prop("checked"));
                      });
                  })
              }
              
           },{escape:true}    
       ); 
  }else{
    // ======== Reset Business Search Errors =========================
      $(obj).next().remove('font');
      $(obj).next().remove('br');
      $(obj).after('<font color="red" class="error-tag">You must search for a minimum of 2 characters.</font><br/>');
  }
}
//======================== Fetch Business Search End ====================================

// ============================= SSN Search Start =================================
$(function(){
  //============== Reset SSN Search =========================
    $('#signor-ssn,#gua2-ssn,#gua3-ssn').click(function(){
         $('.bottom-button1,.associate-btn').show();
         $('.bottom-button2,#ssnresults').hide();
    });
})
//============= SSN Remote Action Save Function ==========================
function callSSNSave(ids,flag,type){
    Visualforce.remoting.Manager.invokeAction(
     'CreditreViewScreenController.saveSSNRecord', 
         ids,
         parentId,
         flag,
         type,
         function(result, event) {
          if (event.status) {
               
            } else if (event.type === 'exception') {
              //alert(event.message);
            } else {
              //alert(event.message);
            }
            /// alert(result);
         },{escape:true}
      )
      getOtherRelatedBusinessesRecord();// Reload Other Related Business Records
      callAssociatedContacts();// Reload Associated Contact Records
      setTimeout(function(){reloadGuarantorPull();},100);
}
//====================== Fetch  SSN Search Record Start =======================================
function callSSNSearch(searchValue){   
    Visualforce.remoting.Manager.invokeAction(
     'CreditreViewScreenController.searchSSN', 
         searchValue,parentId,
         function(result, event) {
         if(result.length > 0){
            var table='<div style="max-height:350px;overflow-y:scroll"><table class="table table-striped table-bordered table-hover">';
              table+='<thead>';
                table+='<tr>';
                  table+='<th>#</th>';
                  table+='<th>Name</th>';
                  table+='<th>Title</th>';
                  table+='<th>Account</th>';
                table+='</tr>';
              table+='</thead>';
              table+='<tbody>';
              for(var index=0;index < result.length; index++){
                var title = result[index].Title !== undefined ?result[index].Title:'N/A';
                table+='<tr>';
                  table+='<td><input class="gurantor-ssn-checkbox" checked="checked" type="checkbox" value="'+result[index].Id+'"  /></td>';
                    table+='<td>'+result[index].Name+' <a href="/'+result[index].Id+'" target="_blank">(View Record)</a></td>';
                  table+='<td>'+title+'</td>';
                  table+='<td>'+result[index].Account.Name+'</td>';
                table+='</tr>';
              }
              table+='</tbody>';
            table+='</table></div>';
            $('#ssnresultsBox').html(table);
            $('#ssnloader,.bottom-button1').hide();
            $('#ssnresults,.bottom-button2').show();
        
            }else{
               $('#ssnloader').show();
            setTimeout(function(){
                  $('#ssnloader,.bottom-button1,.associate-btn').hide();
              $('#ssnresultsBox').html('<br/><center>No Record Found<center>');
                  $('#ssnresults,.bottom-button2').show();
            },500)
            }
         },{escape:true}
     )
}
//====================== Fetch  SSN Search Record End =======================================
var callFromObj;
function searchSSNRecord(callFrom,searchValue,isComplate){
  var contactName = $(callFrom).closest('fieldset').find('[id$="contact_name"]').val();
    callFromObj = callFrom;// Call From Object
    if(searchValue ==''){
      $('#ssnloader').show();
      $('.searchingOf').text(contactName);
      setTimeout(function(){
        $('#ssnloader,.bottom-button1,.associate-btn').hide();
        $('#ssnresultsBox').html('<br/><center>The SSN for this contact has not been provided.<center>');
            $('#ssnresults,.bottom-button2').show();
            if($(callFromObj).has( "i" ).length > 0 ){
          $('#ssn_complete').attr('checked','checked');
        }else{
          $('#ssn_complete').removeAttr('checked');
        }
      },1000)
         
    }else{
      $('#ssnloader').show();
      $('.searchingOf').text(contactName);
      if($(callFromObj).has( "i" ).length > 0 ){
        $('#ssn_complete').attr('checked','checked');
      }else{
        $('#ssn_complete').removeAttr('checked');
      }

    callSSNSearch(searchValue);
    }
    
}
//========= Save SSN ======================================
function saveSSN(check){
    var conIds ='';
    var coma='';
    var error =false;
    if($('.gurantor-ssn-checkbox:checked').length > 0){
      $('.gurantor-ssn-checkbox').each(function(index, element) {
        if($(this).is(':checked')){
               conIds +=coma+$(this).val();
               coma=',';
            } 
     });
  }else{
    error =true;
  }
     var field='';
     if($(callFromObj).attr('id') =='signor-ssn'){
        field='PG1Search__c';
     }
     if($(callFromObj).attr('id') =='gua2-ssn'){
        field='PG2Search__c';
     }  
     if($(callFromObj).attr('id') =='gua3-ssn'){
        field='PG3Search__c';
     }
     var flag ='';
     if(check !== undefined){
        flag = $('#ssn_complete').is(":checked")?'yes':'no';
        conIds='';
     }else{
        ///$('#ssn_complete').is(":checked","checked");
        flag =$('#ssn_complete').is(":checked")?'yes':'no';
     } 
     callSSNSave(conIds,flag,field);
     if(flag !='yes'){
        $(callFromObj).html('SSN Search');
     }else{
        $(callFromObj).html('<i class="fa fa-check-circle"></i> SSN Search');
     }
     if(check === undefined){
        if(error){
          alert('Please select at least 1 Contact to associate.')
        }else{
          $('#G-SSNsearchmodal').modal('hide');
        }
     } 
  
}
//=============== Save SSN by Search Complate ============================
function saveSSNAndClose(){
    saveSSN('yes');
}
//====================== SSN Search End ==================================
//======================== All Bank Account Fetch Start ========================
function callJson(activeTab){
      Visualforce.remoting.Manager.invokeAction(
       'CreditreViewScreenController.getBankTabs', 
           parentId,
           function(result, event) {
            if(result.length > 0){
        var menu ='<li class="active" ><a data-toggle="tab" href="#Summary" onclick="summaryTabCalculation()">Summary</a> </li><li class="last"><a href="#Overeiw" data-toggle="tab">Account Overview</a> </li>';
        var tabs ='';
              for(var i=0; i < result.length; i++){
                var tabName = result[i].Account_Number !== undefined ? result[i].Account_Number : 'N/A';

                menu +='<li><a href="#'+result[i].BankId+'" onClick="checkMonth(\''+result[i].BankId+'\')" data-toggle="tab">'+result[i].TabName+' Acct# '+tabName+'</a> </li>';
                tabs +='<div class="tab-pane tabStyle" id="'+result[i].BankId+'"  data-summaryid="'+result[i].BankSummaryId+'" style="position:relative"><div class="disabledByZ-index"></div>';
                 
                    tabs +='<div class="fa-border" style="margin-top:20px; margin-bottom:20px; width:100%;">';
                      tabs +='<div class="row">';
                          tabs +='<div class="col-md-12" align="center">';
                              tabs +='<input type="button" style="margin-right:5px;" value="Bank Rename" class="btn btn-sm btn-success" onclick="bankRename(\''+result[i].BankId+'\',\''+result[i].TabName+'\',\'' + result[i].Account_Number + '\')" />';

                              tabs +='<input type="button" onclick="showBankDelete(\''+result[i].BankId+'\');$(\'#modify_account\').modal(\'show\')" value="Remove Account" class="btn btn-sm btn-danger"  />';
                          tabs +='</div>';
                        tabs +='</div>';
                        tabs +='<div class="row" >';
                          tabs +='<div class="col-md-2">';
                            tabs +='<div style=" margin-top:10px">';
                              tabs +='<div class="col-md-12">';
                                tabs +='<label class="bank-label-head hidden">s</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Beginning Balance($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label">Deposits(#)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label">Counter Deposits($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Other Deposits($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Withdrawals($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Ending Balance($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Negative Days(#)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> NSFs(#)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Avg Daily Balance($)</label>';
                                tabs +='<br/>';
                              tabs +='</div>';
                            tabs +='</div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-8">';
                            tabs +='<div class="row bankMonthSection row-horizon" onscroll="myScroller(this,\''+result[i].BankSummaryId+'\')">';
                            for(var j=0; j < result[i].Childs.length;j++){
                              //tabs +='<apex:repeat value="{!mlrow.childs}" var="month">';
                                tabs +='<div class="col-md-2 '+result[i].Childs[j].Mr.Month_Name__c+result[i].Childs[j].Mr.Year__c+'">';
                                  tabs +='<div style="width:100%; margin-top:10px">';
                                    tabs +='<table class="table table-bordered month-table">';
                                      tabs +='<label class="bank-label-head">';
                                        if(result[i].Childs[j].Mr.Include_in_Averages__c){
                                          tabs +='<input type="checkbox" class="bankMonthlyCheck" value="'+result[i].Childs[j].Mr.Bank_Monthly_Ledger__c+'" checked="" />'; 
                                        }else{
                                          tabs +='<input type="checkbox" class="bankMonthlyCheck" value="'+result[i].Childs[j].Mr.Bank_Monthly_Ledger__c+'" />';
                                        }
                                        tabs +=' '+result[i].Childs[j].Mr.Month_Name__c+' '+result[i].Childs[j].Mr.Year__c+'</label>';

                                        //alert(parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Beginning_Balance__c))
                                        //alert(parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Beginning_Balance__c).toFixed(2));
                                      tabs +='<tr>';
                                        tabs +='<td><input class="bankRow1" type="text" value="'+parseFloat(result[i].Childs[j].Mr.Beginning_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'" /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow2" value="'+result[i].Childs[j].Mr.Deposits_Number__c+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow3" value="'+parseFloat(result[i].Childs[j].Mr.Counter_Deposits__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow4" value="'+parseFloat(result[i].Childs[j].Mr.Other_Deposits__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow5" value="'+parseFloat(result[i].Childs[j].Mr.Withdrawls__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow6" value="'+parseFloat(result[i].Childs[j].Mr.Ending_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow7"  value="'+result[i].Childs[j].Mr.Negative_Days__c+'" /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow8" value="'+result[i].Childs[j].Mr.NSF__c+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                      /////alert(parseFloat(result[i].Childs[j].Mr.Avg_Daily_Balance__c));
                                        tabs +='<td><input type="text" readonly="readonly" class="bankRow9" value="'+parseFloat(result[i].Childs[j].Mr.Avg_Daily_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                    tabs +='</table>';
                                  tabs +='</div>';
                                tabs +='</div>';
                               } /// End Loop 
                              //tabs +='</apex:repeat>';
                              
                            tabs +='</div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-2">';
                            tabs +='<div style=" margin-top:10px">';
                              tabs +='<div class="col-md-12">';
                                tabs +='<label class="bank-label-head">Average</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow1Label bank-label">$'+result[i].Avg.Column1+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow2Label bank-label">'+result[i].Avg.Column2+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow3Label bank-label">$'+result[i].Avg.Column3+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow4Label bank-label">$'+result[i].Avg.Column4+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow5Label bank-label">$'+result[i].Avg.Column5+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow6Label bank-label"> $'+result[i].Avg.Column6+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow7Label bank-label">'+result[i].Avg.Column7+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow8Label bank-label">'+result[i].Avg.Column8+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow9Label bank-label"> $'+result[i].Avg.Column9+'</label>';
                              tabs +='</div>';
                            tabs +='</div>';
                          tabs +='</div>';
                        tabs +='</div>';
                        tabs +='<hr/>';
                        tabs +='<div class="clearfix"></div>';
                        tabs +='<div class="row">';
                          tabs +='<div class="col-md-12" align="center">';
                              /*tabs +='<input type="button" style="display:none" value="Empty Data" id="'+result[i].BankId+'_emptyChild" class="btn btn-sm btn-danger" onclick="bankChildEmpty(\''+result[i].BankId+'\')" />';*/
                          tabs +='</div>';
                        tabs +='</div>';
                        tabs +='<div class="row">';
                          tabs +='<div class="col-md-2" style="margin-top:30%;">';
                            tabs +='<div class="col-md-10 mt10"> <a data-toggle="modal" class="btn btn-success add1month" onclick="addMonths(this,\'1future\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 1 Month</span> </a> </div>';

                            tabs +='<div class="col-md-10 mt10"> <a data-toggle="modal" class="btn btn-success add3month" onclick="addMonths(this,\'3future\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 3 Month</span> </a> </div>';

                            tabs +='<div class="col-md-10 mt10"> <a class="btn btn-success add6month"  onclick="addMonths(this,\'6future\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 6 Month</span> </a> </div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-8">';
                            tabs +='<div class="row creditMonthSection row-horizon '+result[i].BankSummaryId+'">';
                             for(var k=0; k < result[i].Childs.length;k++){
                              //tabs +='<apex:repeat value="{!mlrow.childs}" var="month">';
                              tabs +='<div class="col-md-2" data-year="'+result[i].Childs[k].Mr.Year__c+'" data-month="'+result[i].Childs[k].Mr.Month__c+'" data-days="'+result[i].Childs[k].DaysInMonth+'" data-id="'+result[i].Childs[k].Mr.Id+'"  data-target="'+result[i].Childs[k].Mr.Month_Name__c+result[i].Childs[k].Mr.Year__c+'">';
                                tabs +='<div style="width:100%; margin-top:10px">';
                                  tabs +='<table class="table table-bordered-custom month-table-bottom">';
                                    tabs +='<label class="bank-label-head text-center ">'+result[i].Childs[k].Mr.Month_Name__c+' '+result[i].Childs[k].Mr.Year__c+'</label>';
                                   // tabs +='<apex:repeat value="{!month.fieldNames}" var="days">';
                                   var dayNo =0;
                                   for(var g=0; g < result[i].Childs[k].FieldNames.length;g++){
                                   dayNo++;
                                    tabs +='<tr>';
                                      /*var monthValue =result[i].Childs[k].Mr[result[i].Childs[k].FieldNames[g]] === undefined || result[i].Childs[k].Mr[result[i].Childs[k].FieldNames[g]] =='' ? result[i].Childs[k].Mr.Bank_Monthly_Ledger__r[result[i].Childs[k].FieldNames[g]] : result[i].Childs[k].Mr[result[i].Childs[k].FieldNames[g]] ; */
                                      var monthValue =result[i].Childs[k].Mr[result[i].Childs[k].FieldNames[g]];
                                      tabs +='<td width="10%" >'+dayNo+'</td>';
                                      tabs +='<td width="90%"><input type="text" value="'+parseFloat(monthValue).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'" /></td>';
                                    tabs +='</tr>';
                                    //tabs +='</apex:repeat>';
                                    }
                                  tabs +='</table>';

                                tabs +='</div>';
                              tabs +='</div>';
                              //tabs +='</apex:repeat>';
                              }
                            tabs +='</div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-2" style="margin-top:30%;">';
                            tabs +='<div class="col-md-10 mt10 " > <a class="btn btn-success"  onclick="addMonths(this,\'1past\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 1 Month</span> </a> </div>';

                              tabs +='<div class="col-md-10 mt10 " > <a class="btn btn-success"  onclick="addMonths(this,\'3past\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 3 Month</span> </a> </div>';

                            tabs +='<div class="col-md-10 mt10 " > <a class="btn btn-success"  onclick="addMonths(this,\'6past\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 6 Month</span> </a> </div>';
                          tabs +='</div>';
                        tabs +='</div>';
                      tabs +='</div>';
                      /// href="#bankmodal"
                      tabs +='<div class="changes-btn"  style="text-align:center; margin-bottom:20px; display:none"> <a  href="javascript:void(0)" class="btn btn-danger" onclick="cancelChanges()" >Cancel Changes</a> <a class="btn btn-success" onClick="saveBankChanges(\''+result[i].BankId+'\')" >Save Changes</a> </div>';
                  tabs +='</div>';
            }// Main Loop Over
              menu +=' <a href="javascript:void(0)" onclick="$(\'#bankmodal-addaccount\').modal(\'show\');getBankData()" class="btn permissionDeny btn-primary pull-right" role="button" >Add Account</a>  <div class="changes-btn pull-right"  style="text-align:center; margin-right:5px; display:none">  <a href="javascript:void(0)" class="btn btn-danger" onclick="cancelChanges()" >Cancel Changes</a> <a class="btn btn-success"  onClick="saveBankChanges(\'\')"  >Save Changes</a> </div>';
              $('.bankTabMenu').html(menu);
              $('.create_tab').nextAll('div').remove();
              $('.create_tab').after(tabs);
              $('.create_tab').parent().find("input[value='NaN']").removeAttr('value');
              $('.create_tab').parent().find("input[value='undefined']").removeAttr('value');
              // Code 1
              
              if(activeTab != ''){
                if(activeTab != 'yes'){
                  $('[href='+activeTab+']').click();
                }else{
                  $('.bankTabMenu li').last().children('a').click();
                }
                
                var tabId = $('.bankTabMenu li').last().children('a').attr('href');
              var month =$(tabId).find('.creditMonthSection div:first-child').attr('data-month');
              var year =$(tabId).find('.creditMonthSection div:first-child').attr('data-year');


              if(new Date(year+'/'+month+'/1') < new Date()){
                if(monthDiff(new Date(year, month-1, 1), new Date()) < 2 ){
              $(tabId).find('.add1month').addClass('btn-default disabled').removeClass('btn-success');

            }else{
              $(tabId).find('.add1month').removeClass('btn-default disabled').addClass('btn-success');
            }
                if(monthDiff(new Date(year, month-1, 1), new Date()) > 6 ){
                  $(tabId).find('.add6month').removeClass('btn-default disabled').addClass('btn-success');
                }else{
                  $(tabId).find('.add6month').addClass('btn-default disabled').removeClass('btn-success');
                }
              }else{
                $(tabId).find('.add1month').addClass('btn-default disabled').removeClass('btn-success');
                $(tabId).find('.add6month').addClass('btn-default disabled').removeClass('btn-success');

              }
                
              }else{
                setTimeout(function(){
                $('.bankTabMenu li').first().children('a').click();
              },1000)
                
              }
              setTimeout(function(){
              decimalValidate();
              averageRecalc();
              dependentScroller();
              getAccountOverViews('yes');
              disabledEvents(creditReviewStatus);
            },2000)
            }else{
              var menu ='<li class="active" ><a data-toggle="tab" href="#Summary" onclick="summaryTabCalculation()">Summary</a> </li><li class="last"><a href="#Overeiw" data-toggle="tab">Account Overview</a> </li>';
              menu +=' <a href="javascript:void(0)" onclick="$(\'#bankmodal-addaccount\').modal(\'show\');getBankData()" class="btn permissionDeny btn-primary pull-right" role="button" >Add Account</a>  <div class="changes-btn pull-right"  style="text-align:center; margin-right:5px; display:none">  <a href="javascript:void(0)" class="btn btn-danger" onclick="cancelChanges()" >Cancel Changes</a> <a class="btn btn-success"  onClick="saveBankChanges(\'\')"  >Save Changes</a> </div>';

              $('.bankTabMenu').html(menu);
              $('.create_tab').nextAll('div').remove();
              setTimeout(function(){
                $('.startDate,.endDate').val('');
              getAccountOverViews('yes');
              $('[href=#Overeiw]').click();
            },1000)
            
            }
           }
    )
        
        
   }
 // ======================= All Bank Account Fetch End =============================
 //======================== Single Bank Account Fetch Start ========================
function singleBankAccountFetch(activeTab,totalRecord){
  var bankId ='';
      Visualforce.remoting.Manager.invokeAction(
       'CreditreViewScreenController.getSingleBankTab', 
           parentId,
           totalRecord,
           function(result, event) {
            if(result.length > 0){
        var menu ='';
        var tabs ='';
              for(var i=0; i < result.length; i++){
                bankId = result[i].BankId;
                var tabName = result[i].Account_Number !== undefined ? result[i].Account_Number : 'N/A';
                menu +='<li><a href="#'+result[i].BankId+'" onClick="checkMonth(\''+result[i].BankId+'\')" data-toggle="tab">'+result[i].TabName+' Acct# '+tabName+'</a> </li>';
                tabs +='<div class="tab-pane tabStyle" id="'+result[i].BankId+'"  data-summaryid="'+result[i].BankSummaryId+'" style="position:relative"><div class="disabledByZ-index"></div>';
                    tabs +='<div class="fa-border" style="margin-top:20px; margin-bottom:20px; width:100%;">';
                      tabs +='<div class="row">';
                          tabs +='<div class="col-md-12" align="center">';
                              tabs +='<input type="button" style="margin-right:5px;" value="Bank Rename" class="btn btn-sm btn-success" onclick="bankRename(\''+result[i].BankId+'\',\''+result[i].TabName+'\',\'' + result[i].Account_Number + '\')" />';

                              tabs +='<input type="button" onclick="showBankDelete(\''+result[i].BankId+'\');$(\'#modify_account\').modal(\'show\');" value="Remove Account" class="btn btn-sm btn-danger"  />';
                          tabs +='</div>';
                        tabs +='</div>';
                        tabs +='<div class="row" >';
                          tabs +='<div class="col-md-2">';
                            tabs +='<div style=" margin-top:10px">';
                              tabs +='<div class="col-md-12">';
                                tabs +='<label class="bank-label-head hidden">s</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Beginning Balance($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label">Deposits(#)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label">Counter Deposits($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Other Deposits($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Withdrawls($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Ending Balance($)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Negative Days(#)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> NSFs(#)</label>';
                                tabs +='<br/>';
                                tabs +='<label class=" bank-label"> Avg Daily Balance($)</label>';
                                tabs +='<br/>';
                              tabs +='</div>';
                            tabs +='</div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-8">';
                            tabs +='<div class="row bankMonthSection row-horizon" onscroll="myScroller(this,\''+result[i].BankSummaryId+'\')">';
                            for(var j=0; j < result[i].Childs.length;j++){
                              //tabs +='<apex:repeat value="{!mlrow.childs}" var="month">';
                                tabs +='<div class="col-md-2 '+result[i].Childs[j].Mr.Month_Name__c+result[i].Childs[j].Mr.Year__c+'">';
                                  tabs +='<div style="width:100%; margin-top:10px">';
                                    tabs +='<table class="table table-bordered month-table">';
                                      tabs +='<label class="bank-label-head">';
                                        if(result[i].Childs[j].Mr.Include_in_Averages__c){
                                          tabs +='<input type="checkbox" class="bankMonthlyCheck" value="'+result[i].Childs[j].Mr.Bank_Monthly_Ledger__c+'" checked="" />'; 
                                        }else{
                                          tabs +='<input type="checkbox" class="bankMonthlyCheck" value="'+result[i].Childs[j].Mr.Bank_Monthly_Ledger__c+'" />';
                                        }
                                        tabs +=' '+result[i].Childs[j].Mr.Month_Name__c+' '+result[i].Childs[j].Mr.Year__c+'</label>';
                                      tabs +='<tr>';
                                        tabs +='<td><input class="bankRow1" type="text" value="'+parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Beginning_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'" /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow2" value="'+result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Deposits_Count__c+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow3" value="'+parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Counter_Deposits__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow4" value="'+parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Other_Deposits__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow5" value="'+parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Withdrawls__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow6" value="'+parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Ending_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow7"  value="'+result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Negative_Days__c+'" /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" class="bankRow8" value="'+result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.NSF_s__c+'"  /></td>';
                                      tabs +='</tr>';
                                      tabs +='<tr>';
                                        tabs +='<td><input type="text" readonly="readonly" class="bankRow9" value="'+parseFloat(result[i].Childs[j].Mr.Bank_Monthly_Ledger__r.Avg_Daily_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
                                      tabs +='</tr>';
                                    tabs +='</table>';
                                  tabs +='</div>';
                                tabs +='</div>';
                               } /// End Loop 
                              //tabs +='</apex:repeat>';
                              
                            tabs +='</div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-2">';
                            tabs +='<div style=" margin-top:10px">';
                              tabs +='<div class="col-md-12">';
                                tabs +='<label class="bank-label-head">Average</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow1Label bank-label">$'+result[i].Avg.Column1+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow2Label bank-label">'+result[i].Avg.Column2+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow3Label bank-label">$'+result[i].Avg.Column3+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow4Label bank-label">$'+result[i].Avg.Column4+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow5Label bank-label">$'+result[i].Avg.Column5+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow6Label bank-label"> $'+result[i].Avg.Column6+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow7Label bank-label">'+result[i].Avg.Column7+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow8Label bank-label">'+result[i].Avg.Column8+'</label>';
                                tabs +='<br/>';
                                tabs +='<label class="bankRow9Label bank-label"> $'+result[i].Avg.Column9+'</label>';
                              tabs +='</div>';
                            tabs +='</div>';
                          tabs +='</div>';
                        tabs +='</div>';
                        tabs +='<hr/>';
                        tabs +='<div class="clearfix"></div>';
                        tabs +='<div style="margin-top:20px; margin-bottom:20px; width:100%;">';
                      /*tabs +='<div class="row">';
                          tabs +='<div class="col-md-12" align="center">';
                              tabs +='<input type="button" style="display:none" value="Empty Data" id="'+result[i].BankId+'_emptyChild" class="btn btn-sm btn-danger" onclick="bankChildEmpty(\''+result[i].BankId+'\')" />'; 
                          tabs +='</div>';
                        tabs +='</div>';*/
                        tabs +='<div class="row">';
                          tabs +='<div class="col-md-2" style="margin-top:30%;">';
                            tabs +='<div class="col-md-10 mt10"> <a data-toggle="modal" class="btn btn-success add1month" onclick="addMonths(this,\'1future\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 1 Month</span> </a> </div>';

                            tabs +='<div class="col-md-10 mt10"> <a data-toggle="modal" class="btn btn-success add3month" onclick="addMonths(this,\'3future\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 3 Month</span> </a> </div>';


                            tabs +='<div class="col-md-10 mt10"> <a class="btn btn-success add6month"  onclick="addMonths(this,\'6future\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 6 Month</span> </a> </div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-8">';
                            tabs +='<div class="row creditMonthSection row-horizon '+result[i].BankSummaryId+'">';
                             for(var k=0; k < result[i].Childs.length;k++){
                              //tabs +='<apex:repeat value="{!mlrow.childs}" var="month">';
                              tabs +='<div class="col-md-2" data-year="'+result[i].Childs[k].Mr.Year__c+'" data-month="'+result[i].Childs[k].Mr.Month__c+'" data-days="'+result[i].Childs[k].DaysInMonth+'" data-id="'+result[i].Childs[k].Mr.Id+'"  data-target="'+result[i].Childs[k].Mr.Month_Name__c+result[i].Childs[k].Mr.Year__c+'">';
                                tabs +='<div style="width:100%; margin-top:10px">';
                                  tabs +='<table class="table table-bordered-custom month-table-bottom">';
                                    tabs +='<label class="bank-label-head text-center ">'+result[i].Childs[k].Mr.Month_Name__c+' '+result[i].Childs[k].Mr.Year__c+'</label>';
                                   // tabs +='<apex:repeat value="{!month.fieldNames}" var="days">';
                                   var dayNo =0;
                                   for(var g=0; g < result[i].Childs[k].FieldNames.length;g++){
                                   dayNo++;
                                    tabs +='<tr>';
                                    var monthValue =result[i].Childs[k].Mr[result[i].Childs[k].FieldNames[g]] === undefined || result[i].Childs[k].Mr[result[i].Childs[k].FieldNames[g]] =='' ? result[i].Childs[k].Mr.Bank_Monthly_Ledger__r[result[i].Childs[k].FieldNames[g]] : result[i].Childs[k].Mr[result[i].Childs[k].FieldNames[g]] ;
                                    /*var monthValue =result[i].Childs[k].Mr.Bank_Monthly_Ledger__r[result[i].Childs[k].FieldNames[g]] ; */
                                      tabs +='<td width="10%" >'+dayNo+'</td>';
                                      tabs +='<td width="90%"><input type="text" value="'+parseFloat(monthValue).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'" /></td>';
                                    tabs +='</tr>';
                                    //tabs +='</apex:repeat>';
                                    }
                                  tabs +='</table>';

                                tabs +='</div>';
                              tabs +='</div>';
                              //tabs +='</apex:repeat>';
                              }
                            tabs +='</div>';
                          tabs +='</div>';
                          tabs +='<div class="col-md-2" style="margin-top:30%;">';
                            tabs +='<div class="col-md-10 mt10 " > <a class="btn btn-success"  onclick="addMonths(this,\'1past\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 1 Month</span> </a> </div>';

                            tabs +='<div class="col-md-10 mt10 " > <a class="btn btn-success"  onclick="addMonths(this,\'3past\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 3 Month</span> </a> </div>';


                            tabs +='<div class="col-md-10 mt10 " > <a class="btn btn-success"  onclick="addMonths(this,\'6past\')"> <i class="fa fa-plus-circle fa-4x" style="  margin-top: 10px;"></i><br/>';
                              tabs +='<span class="mt10">Add 6 Month</span> </a> </div>';
                          tabs +='</div>';
                        tabs +='</div>';
                      tabs +='</div>';
                      /// href="#bankmodal"
                      tabs +='<div class="changes-btn"  style="text-align:center; margin-bottom:20px; display:none"> <a  href="javascript:void(0)" class="btn btn-danger" onclick="cancelChanges()" >Cancel Changes</a> <a class="btn btn-success" onClick="saveBankChanges(\''+result[i].BankId+'\')" >Save Changes</a> </div>';
                  tabs +='</div></div>';
            }// Main Loop Over
              //menu +=' <a href="javascript:void(0)" onclick="$(\'#bankmodal-addaccount\').modal(\'show\');getBankData()" class="btn permissionDeny btn-primary pull-right" role="button" >Add Account</a>';
              $('.bankTabMenu li').last().after(menu);
              $('.bankTabContent').append(tabs);
              $('.bankTabContent').find("input[value='NaN']").removeAttr('value');
              $('.bankTabContent').find("input[value='undefined']").removeAttr('value'); 

              if(activeTab != ''){
                if(activeTab != 'yes'){
                  $('[href='+activeTab+']').click();
                }else{
                  $('.bankTabMenu li').last().children('a').click();
                }
                
                var tabId = $('.bankTabMenu li').last().children('a').attr('href');
              var month =$(tabId).find('.creditMonthSection div:first-child').attr('data-month');
              var year =$(tabId).find('.creditMonthSection div:first-child').attr('data-year');

              if(new Date(year+'/'+month+'/1') < new Date()){
                if(monthDiff(new Date(year, month-1, 1), new Date()) < 2 ){
              $(tabId).find('.add1month').addClass('btn-default disabled').removeClass('btn-success');

            }else{
              $(tabId).find('.add1month').removeClass('btn-default disabled').addClass('btn-success');
            }
                if(monthDiff(new Date(year, month-1, 1), new Date()) > 6 ){
                  $(tabId).find('.add6month').removeClass('btn-default disabled').addClass('btn-success');
                }else{
                  $(tabId).find('.add6month').addClass('btn-default disabled').removeClass('btn-success');
                }
              }else{
                $(tabId).find('.add1month').addClass('btn-default disabled').removeClass('btn-success');
                $(tabId).find('.add6month').addClass('btn-default disabled').removeClass('btn-success');

              }
                
              }else{
                /*setTimeout(function(){
                $('.bankTabMenu li').first().children('a').click();
              },1000)*/
                
              }
            }else{

            }
           }
    )
        setTimeout(function(){
          decimalValidate();
          allRowAvgCalculate(bankId,'');
          dependentScroller();
          getAccountOverViews('yes');
          dailyAvg();
          averageRecalc();
        },3000)
        
   }
  // Show Delete Button for Delete Bank Tab
 function showBankDelete(id){
  var tabs ='';
  id = id.replace('#','');
  ///var hasData = false;
  if($('#'+id).find('input[type=text]').filter(function() { return this.value != ""; }).length){
    hasData = true;
  }else{
    hasData = false;
  }
  //alert(hasData);
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.hasBankData',
     parentId, 
       id,     
       function(result, event) {
      if(hasData || result == 'yes'){
          tabs +='<input type="button" style="margin-bottom:5px;" value="Remove from Credit Review" class="btn btn-sm btn-danger btn-block" onclick="bankDelete(\''+id+'\')" />';
        }else{
          tabs +='<input type="button" style="margin-bottom:5px;" value="Remove from Account" class="btn btn-sm btn-danger btn-block" onclick="bankDataDelete(\''+id+'\')" />';
          tabs +='<input type="button" style="margin-bottom:5px;" value="Remove from Credit Review" class="btn btn-sm btn-danger btn-block" onclick="bankDelete(\''+id+'\')" />';
        }
        tabs +='<input type="button" style="margin-bottom:5px;" value="Cancel" class="btn btn-sm btn-danger btn-block" onclick="$(\'#modify_account\').modal(\'hide\')" />';
      $('.account-buttons').html(tabs);
        
       },{escape:true}
    );
  
 }
 function showRemoveDataButtons(id){
  var count =0;
  var tabs ='';
  if($(id).find('.bankMonthSection input[type=text]').not('.bankRow9').filter(function() { return this.value != ""; }).length){
    count ++;

  }
  if($(id).find('.creditMonthSection input[type=text]').filter(function() { return this.value != ""; }).length){
    count ++;
  }
  if(count >1){
      tabs +='<input type="button" style="margin-bottom:5px;" value="Remove from Account" class="btn btn-sm btn-danger btn-block" onclick="bankDelete(\''+id+'\')" />';

      tabs +='<input type="button" value="Remove from Credit Review" style="margin-bottom:5px"  class="btn btn-sm btn-danger btn-block" onclick="bankChildEmpty(\''+id+'\')" />';
  }
  if(count ==1){
    tabs +='<input type="button" style="margin-bottom:5px;" value="Remove from Account" class="btn btn-sm btn-danger btn-block" onclick="bankDelete(\''+id+'\')" />';
  }
  if(count != 0)
    $('.account-buttons').html(tabs);
 }
 // Show Bank Empty Button
 function showBankEmpty(id){
  if($(id).find('.bankMonthSection input[type=text]').not('.bankRow9').filter(function() { return this.value != ""; }).length){
    $(id+'_emptyBank').show();
  }else{
    $(id+'_emptyBank').hide();  
    
  }
 }
 // Show Bank Monthly Empty Button
 function showBankChildEmpty(id){
  if($(id).find('.creditMonthSection input[type=text]').filter(function() { return this.value != ""; }).length){
    $(id+'_emptyChild').show();
  }else{
    $(id+'_emptyChild').hide(); 
    
  }
 }
 // Delete Bank Monthly Ledgers
 function bankDelete(id){
  r = confirm('Are you sure!');
  if(r){
    id = id.replace('#','');
    $('#modify_account').modal('hide');
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.removeCreditBank',
       parentId, 
         id,     
         function(result, event) {
          callJson('yes');
          
         },{escape:true}
      );
     setTimeout(function(){
    $('#processing').modal('hide');       
     },3500) 
  }else{

  }
  
 }
 // Delete Bank Data 
 function bankDataDelete(id){
  r = confirm('Are you sure!');
  if(r){
    id = id.replace('#','');
    $('#modify_account').modal('hide');
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.removeBank',
       parentId, 
         id,     
         function(result, event) {
          callJson('yes');
          
         },{escape:true}
      );
     setTimeout(function(){
    $('#processing').modal('hide');       
     },3500) 
  }else{

  }
  
 }

 function bankEmpty(id){
  r = confirm('Are you Sure!');
  if(r){
    id = id.replace('#','');
    $('#modify_account').modal('hide');
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.emptyBankData',
       parentId,
       id,    
         function(result, event) {
          if (event.status) {
            callJson('#'+id);
            
            } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
            
           },{escape:true}
        );
        setTimeout(function(){
        $('#processing').modal('hide');       
      },2000)
  }else{

  }
 }
 function bankChildEmpty(id){
  r = confirm('Are you Sure!');
  if(r){
    id = id.replace('#','');
    $('#modify_account').modal('hide');
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.emptyBottomData',
       parentId,
       id,    
         function(result, event) {
          if (event.status) {
            callJson('#'+id);
          } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
            
           },{escape:true}
        );
       setTimeout(function(){
          $('#processing').modal('hide');       
       },2000)
  }else{

  }
 }
 function bankAllEmpty(id){
  r = confirm('Are you Sure!');
  if(r){
    id = id.replace('#','');
    $('#modify_account').modal('hide');
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.removeAllData',
       parentId,
       id,    
         function(result, event) {
          if (event.status) {
            callJson('#'+id);
          } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
            
           },{escape:true}
        );
       setTimeout(function(){
          $('#processing').modal('hide');       
       },2000)
  }else{

  }
 }
 function bankRename(id,name,acct){
  var r = confirm('Are you sure!');
  if(r){
    $('#rename-id').val(id);
    $('#new-name').val(name);
    $('#new-acct-number').val(acct);
    $('#rename').modal('show');
  }
 }

function rename_save() {
  var name = $('#new-name').val();
  var acctnum = $('#new-acct-number').val();
  if(name == ''){
    alert('Bank Name is Required!')
  } else if (acctnum == '') {
    alert('Bank Account Number is Required!')
  }else{
    $('#rename').modal('hide');
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.changeBankname',
       $('#rename-id').val(),
       $('#new-name').val(),    
       $('#new-acct-number').val(),    
       parentId,
         function(result, event) {
          if (event.status) {
            if(result) {
              // Primary bank. Change the fields in the approve box too
              var bankLast4 = acctnum.substring(acctnum.length-4, acctnum.length)
              $('.approve-acct').val(bankLast4);
              $('.approve-bank_name').val(name);
              $('.acct-output').text(bankLast4);
              $('.bank_name-output').text(name);
            }
            callJson('#'+$('#rename-id').val());
          } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
            
           },{escape:true}
        );
       setTimeout(function(){
          $('#processing').modal('hide');       
       },2000)
  }
 }
 // ======================= Single Bank Account Fetch End =============================
 // =========== Save all Bank Changes ================
 /*function saveTopBankChanges(checkboxValue,recordId,recordValue){
  ////alert(checkboxValue+','+recordId+','+recordValue);
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.insertTopBankChanges',
       checkboxValue, 
         recordId,
         recordValue,      
         function(result, event) {
         },{escape:true}
      );
 }
 function saveBottomBankChanges(monthDays,recordId,recordValue){
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.insertBottomBankChanges',
       monthDays, 
         recordId,
         recordValue,      
         function(result, event) {
         },{escape:true}
      );
 }*/
 function saveAllBankChanges(checkboxValue,topRecordId,topRecordValue,bottomRecordId,bottomRecordValue){
 //alert(checkboxValue+'/n'+topRecordId+'/n'+topRecordValue+'/n'+bottomRecordId+'/n'+bottomRecordValue);
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.insertAllBankChanges',
       checkboxValue,
       topRecordId,
       topRecordValue,
       bottomRecordId,
       bottomRecordValue,    
         function(result, event) {
          /*if (event.status) {
               
            } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }*/
         },{escape:true}
      );
 }
 function saveGeneratedMonths(year,month,bankId,summaryId,topInput,bottomInput,checkboxValue){
 ///alert(year+','+month+','+bankId+','+summaryId+','+topInput+','+bottomInput);
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.saveNewMonths',
       year+','+month,bankId,summaryId,topInput,bottomInput,checkboxValue,     
         function(result, event) {
          if (event.status) {
               
            } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
         },{escape:true}
      );
 }
 //============================= Cancel Changes =============
 function cancelChanges(){
  r = confirm('Are you sure you wish to cancel all of your changes?');
  if(r){
    callJson($('.bankTabMenu li.active a').attr('href'));
    $('.changes-btn').hide(500);
    $('[href="#business"],[href="#guarantor"],[href="#Decision"]').removeClass('disabled');
    window.onbeforeunload = function() {
        null;
     };
    bankChanges = false;
    summaryTabCalculation();
  }else{

  }
 }

 /// ======================= Save Changes Bank Account Start  ====================
 function saveBankChanges(id){
  id = id ==''? $('.bankTabMenu li.active a').attr('href').replace('#',''): id;
  $('#processing').modal('show');
  // Get All Tab Ids
  $('.bankTabMenu li.last').nextAll().each(function(){
    if($(this).children('a').attr('href') !== undefined){
      var id = $(this).children('a').attr('href');
      // Buttom/Top Change Record Save
      $(id).find('.creditMonthSection').children('.col-md-2').not('.newCol').each(function(){
        var monthDays = $(this).attr('data-days');
        var bottomRecordId = $(this).attr('data-id');
        var target = $(this).attr('data-target');
        var bottomRecordValue='';
        coma='';
        $(this).find('input').each(function(index ){
          var v = $(this).val() != '' ? parseFloat($(this).val().replace(/,/g, '')) :'null';
          bottomRecordValue+=coma+v;
          coma=',';
        });
        // Top Bank Records 
        var bankCheckbox = $(id).find('.bankMonthSection').children('.'+target).find('.bankMonthlyCheck');
        var checkboxValue = $(id).find('.bankMonthSection').children('.'+target).find('.bankMonthlyCheck').is(":checked")?'yes':'no';
        var topRecordId = bankCheckbox.val();
        var topRecordValue='';
        coma='';
        $(id).find('.bankMonthSection').children('.'+target).find('input[type=text]').each(function(index ){
          var v = $(this).val() != '' ? parseFloat($(this).val().replace(/,/g, '')) : 'null';
          topRecordValue+=coma+v;
          coma=',';
        });
        saveAllBankChanges(checkboxValue,topRecordId,topRecordValue,bottomRecordId,bottomRecordValue);
      })
      // New row save
      $(id).find('.creditMonthSection').children('.newCol').each(function(){
        var year = $(this).attr('data-year');
        var month = $(this).attr('data-month');
        var bankId = $(this).attr('data-bankid');
        var summaryId = $(this).attr('data-summaryid');
        var target = $(this).attr('data-target');
        var checkboxValue = $(id).find('.bankMonthSection').children('.'+target).find('.bankMonthlyCheck').is(":checked")?'yes':'no';
        var topInput='';
        coma='';
        $(id).find('.bankMonthSection').children('.'+target).find('input[type=text]').each(function(index ){
          var v = $(this).val() != '' ? parseFloat($(this).val().replace(/,/g, '')) :'null';
          topInput+=coma+v;
          coma=',';
        });
        var bottomInput='';
        coma='';
        $(this).find('input').each(function(index ){
          var v = $(this).val() != '' ? parseFloat($(this).val().replace(/,/g, '')) :'null';
          bottomInput+=coma+v;
          coma=',';
        });
        saveGeneratedMonths(year,month,bankId,summaryId,topInput,bottomInput,checkboxValue);
      })
    }
  })
  
  $('.changes-btn').hide(500);
    $('[href="#business"],[href="#guarantor"],[href="#Decision"]').removeClass('disabled');
  window.onbeforeunload = function() {
      null;
   };
  bankChanges = false;
  setTimeout(function(){
    callJson('#'+id);
    $('#processing').modal('hide');
    dailyAvg();
  },10000)
  
 }
 //========================= Save Changes Bank Account End ==========

 // ========================= Fill Add Months Records start ===================
function fetchMonthsRecords(result,obj,bankId,summaryId,type){
  var creditMonthSection =$('#'+bankId).find('.creditMonthSection');
    var bankMonthSection =$('#'+bankId).find('.bankMonthSection');
    var cols='';  
    var bankCols='';
    if(type !='past'){
        result.reverse();
      }
    for(var i=0; i < result.length;i++){

      cols +='<div class="col-md-2 newCol" data-target="'+result[i].MonthName+result[i].Year+'" data-year="'+result[i].Year+'" data-month="'+result[i].Month+'" data-bankid="'+bankId+'" data-summaryid="'+summaryId+'" >';
        cols +='<div style="width:100%; margin-top:10px">';
          cols +='<table class="table table-bordered-custom month-table-bottom" data-days="'+result[i].DaysInMonth+'">';
            cols +='<label class="bank-label-head text-center ">'+result[i].MonthName+' '+result[i].Year+'</label>';
           var dayNo =0;
           for(var j=0; j < result[i].FieldNames.length;j++){
           dayNo++;
           try { 
              var monthValue =typeof(result[i].Mr.Bank_Monthly_Ledger__r[result[i].FieldNames[j]])  === "undefined"?'':result[i].Mr.Bank_Monthly_Ledger__r[result[i].FieldNames[j]]; 
              cols +='<tr>';
                cols +='<td width="10%" >'+dayNo+'</td>';
                cols +='<td width="90%"><input type="text" value="'+parseFloat(monthValue).toFixed(2)+'" /></td>';
              cols +='</tr>';
      }catch(err) {
              cols +='<tr>';
                cols +='<td width="10%" >'+dayNo+'</td>';
                cols +='<td width="90%"><input type="text" /></td>';
              cols +='</tr>';
      }
         }
          cols +='</table>';

        cols +='</div>';
      cols +='</div>';
     // ====================== bank cols =========================
      bankCols +='<div class="col-md-2 newBankCol '+result[i].MonthName+result[i].Year+'" data-bankid="'+bankId+'" data-summaryid="'+summaryId+'" >';
        bankCols +='<div style="width:100%; margin-top:10px">';
          bankCols +='<table class="table table-bordered month-table">';
            bankCols +='<label class="bank-label-head">';
              bankCols +='<input type="checkbox" checked="checked" class="bankMonthlyCheck"/> '+result[i].MonthName+' '+result[i].Year+'</label>';
              bankCols +='<tr>';
                bankCols +='<td><input class="bankRow1" type="text" value="'+parseFloat(result[i].bml.Beginning_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'" /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
                bankCols +='<td><input type="text" class="bankRow2" value="'+result[i].bml.Deposits_Count__c+'"  /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
                bankCols +='<td><input type="text" class="bankRow3" value="'+parseFloat(result[i].bml.Counter_Deposits__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
                bankCols +='<td><input type="text" class="bankRow4" value="'+parseFloat(result[i].bml.Other_Deposits__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
                bankCols +='<td><input type="text" class="bankRow5" value="'+parseFloat(result[i].bml.Withdrawls__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
                bankCols +='<td><input type="text" class="bankRow6" value="'+parseFloat(result[i].bml.Ending_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
                bankCols +='<td><input type="text" class="bankRow7"  value="'+result[i].bml.Negative_Days__c+'" /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
                bankCols +='<td><input type="text" class="bankRow8" value="'+result[i].bml.NSF_s__c+'"  /></td>';
              bankCols +='</tr>';
              bankCols +='<tr>';
              bankCols +='<td><input type="text" readonly="readonly" class="bankRow9" value="'+parseFloat(result[i].bml.Avg_Daily_Balance__c).toFixed(2).toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'"  /></td>';
            bankCols +='</tr>';
          bankCols +='</table>';
        bankCols +='</div>';
      bankCols +='</div>';
      }
      
      if(type !="past"){
        creditMonthSection.prepend(cols);
        bankMonthSection.prepend(bankCols);
      }else{
    creditMonthSection.append(cols);
    bankMonthSection.append(bankCols);
      }
      checkMonth(bankId);
      
      setTimeout(function(){
        $('.bankTabContent').find("input[value='NaN']").removeAttr('value');
        $('.bankTabContent').find("input[value='undefined']").removeAttr('value');
        // Call Decimal Validation
        decimalValidate();
        averageRecalc();
        allRowAvgCalculate(bankId,'');
        dependentScroller();
        dailyAvg();
      },2000)
  
}
 // ========================= Fill Add Months Records end ===================
 //================= Add Bank Months ========================

 function addMonths(obj,monthType){
  var bankId = $(obj).closest('.tabStyle').attr('id');
  var summaryId = $(obj).closest('.tabStyle').attr('data-summaryid');
  var month =$('#'+bankId).find('.creditMonthSection').children('div').first().attr('data-month');
    var year =$('#'+bankId).find('.creditMonthSection').children('div').first().attr('data-year');
    var monthPast =$('#'+bankId).find('.creditMonthSection').children('div').last().attr('data-month');
    var yearPast =$('#'+bankId).find('.creditMonthSection').children('div').last().attr('data-year');
    ///alert(month+','+monthPast+','+yearPast);
    var type ='';
    var range ='';
    var finalMonth ='';
    var finalYear = '';
  if(monthType =='1future'){
    range = '1';
    finalMonth = month
    finalYear = year
    type ='future';
  }
  if(monthType =='3future'){
    range = '3';
    finalMonth = month
    finalYear = year
    type ='future';
  }
  if(monthType =='6future'){
    range = '6';
    finalMonth = month
    finalYear = year
    type ='future';
  }
  if(monthType =='1past'){
    range = '1';
    finalMonth = monthPast
    finalYear = yearPast
    type ='past';
  }
  if(monthType =='3past'){
    range = '3';
    finalMonth = monthPast
    finalYear = yearPast
    type ='past';
  }
  if(monthType =='6past'){
    range = '6';
    finalMonth = monthPast
    finalYear = yearPast
    type ='past';
  }
  $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.createMonths', 
         bankId,
         summaryId, 
         type,
         finalMonth+','+finalYear+','+range,      
         function(result, event) {
          fetchMonthsRecords(result,obj,bankId,summaryId,type)
          setTimeout(function(){
            $('#processing').modal('hide');
            
          },2000)
          
         },{escape:true}
      );
    if(!bankChanges){
    $('[href="#business"],[href="#guarantor"],[href="#Decision"]').addClass('disabled');
    $('.changes-btn').show(500);
    window.onbeforeunload = function() {
        return "You have unsaved changes. Are you sure you want to leave this page? All changes will be lost.";
     };
    $("[data-toggle='tab']").click(function(){
        if($(this).hasClass("disabled")){
          alert('Please save your changes before switching tabs. If you do not wish to save your changes, please click \'Cancel Changes\' on the bottom of this page.');
            return false;
        }
    });
  }
  bankChanges = true;
 }
 function checkMonth(id){
  var tabId ='#'+id;
  //var month =$(tabId).find('.creditMonthSection div:first-child').attr('data-month');
    //var year =$(tabId).find('.creditMonthSection div:first-child').attr('data-year');
    var month =$(tabId).find('.creditMonthSection').children('div').first().attr('data-month');
    var year =$(tabId).find('.creditMonthSection').children('div').first().attr('data-year');
  if(new Date(year+'/'+month+'/1') < new Date()){
    if(monthDiff(new Date(year, month-1, 1), new Date()) < 2 ){
      $(tabId).find('.add1month').addClass('btn-default disabled').removeClass('btn-success');
    }else{
      $(tabId).find('.add1month').removeClass('btn-default disabled').addClass('btn-success');
    }

    if(monthDiff(new Date(year, month-1, 1), new Date()) < 4 ){
      $(tabId).find('.add3month').addClass('btn-default disabled').removeClass('btn-success');
    }else{
      $(tabId).find('.add3month').removeClass('btn-default disabled').addClass('btn-success');
    }
    
    if(monthDiff(new Date(year, month-1, 1), new Date()) > 6 ){
      $(tabId).find('.add6month').removeClass('btn-default disabled').addClass('btn-success');
    }else{
      $(tabId).find('.add6month').addClass('btn-default disabled').removeClass('btn-success');
    }
  }else{
    $(tabId).find('.add1month').addClass('btn-default disabled').removeClass('btn-success');
    $(tabId).find('.add6month').addClass('btn-default disabled').removeClass('btn-success');
  }
  //Delete Bank Data
  //showBankChildEmpty(tabId);
  //showBankEmpty(tabId);
  //showBankDelete(tabId);
  //showRemoveDataButtons(tabId);
 }
//======================= Bank Account Create Start ==================
function saveNewBankAccount() {
  var bankName = $('.bank_name').val();
  var accountNumber = $('.account_number').val() !=''?$('.account_number').val():'null';
  //alert(accountNumber);
  var routingNo = $('.routing_no').val() !=''?$('.routing_no').val():'null';
  var range = $('.new-account-range').val();
  var endDate = $('.new-account-end_date').val();
  var monthYear = endDate.split(' ');

  $('.bank_name').next('font').remove();
  $('.routing_no').next('font').remove();
  var noError =true;
  if(bankName == ''){
    $('.bank_name').after('<font color="red" class="error-tag">Bank Name is Required !</font>');
    noError = false;
  }
  if(routingNo != 'null'){
    if(routingNo.length < 9){
      $('.routing_no').after('<font color="red" class="error-tag">Routing Number must have 9 characters or be blank (null) !</font>');
      noError = false;
    }
  }
  if(noError){
      $('#addBankAccountMain').hide()
      $('#addBankAccount-process').show();
      $('.bank_name').next('font').remove();
      $('.routing_no').next('font').remove();
        Visualforce.remoting.Manager.invokeAction(
        'CreditreViewScreenController.addNewBankAccount', 
           parentId,
           accountId,
           bankName+','+accountNumber+','+routingNo,
           monthYear[0]+','+monthYear[1]+','+range, 
                  
           function(result, event) {
            if (event.status) {
              if(result =='yes'){
                var bankNo = $('.account_number').val();
                var bankLast4 = bankNo.substring(bankNo.length-4, bankNo.length)
                $('.approve-acct').val(bankLast4);
                $('.approve-bank_name').val($('.bank_name').val())
                $('.acct-output').text(bankLast4);
                $('.bank_name-output').text($('.bank_name').val());
              }
                    singleBankAccountFetch('yes','1'); 
              ///summaryTabCalculation();
              setTimeout(function(){
                $('#bankmodal-addaccount').modal('hide');
              },2000)
                } else if (event.type === 'exception') {
                  //alert(event.message)
                   if(event.message.indexOf('DUPLICATE_VALUE') != -1){
                      alert('Duplicate Bank Name Found with Account Number. Please Change Account Number');
                   }
                   $('#addBankAccount-process').hide();
          $('#addBankAccountMain').show();
          $('.bank_name,.account_number,.routing_no').val('');
          $('.new-account-range').val('6');
          $('.new-account-end_date option').prop("selected", false);
                } else {
                  alert(event.message);
                  $('#addBankAccount-process').hide();
          $('#addBankAccountMain').show();
          $('.bank_name,.account_number,.routing_no').val('');
          $('.new-account-range').val('6');
          $('.new-account-end_date option').prop("selected", false);
                }
            
           },{escape:true}
        );
    
    }
}

//===================== associateAccount Save ===============
function associateAccount(){
  var range = $('.exists-account-range').val();
  var endDate = $('.exists-account-end_date').val();
  var monthYear = endDate.split(' ');

  if($('.exists-bank-checkbox:checked').length ==0){
    alert('Please select at least 1 bank account to associate.');
  }else{
    $('#addBankAccountMain').hide()
      $('#addBankAccount-process').show();
      var bankIds =[];
      var Months=[];
    $('.exists-bank-checkbox:checked').each(function(){
      var bankId = $(this).val();
      var bankName = $(this).closest('tr').find('td').eq(1).text();
      var bankNo = $(this).closest('tr').find('td').eq(2).text() !='N/A' ? $(this).closest('tr').find('td').eq(2).text() :'';
      bankIds.push(bankIds);
      Months.push(monthYear[0]+','+monthYear[1]+','+range);
      Visualforce.remoting.Manager.invokeAction(
          'CreditreViewScreenController.addAssociateAccount', 
             parentId,
             bankId,
             monthYear[0]+','+monthYear[1]+','+range,         
             function(result, event) {
              if (event.status) {
                    if(result =='yes'){
                                      var bankNo = $('.account_number').val();
                var bankLast4 = bankNo.substring(bankNo.length-4, bankNo.length)
                  $('.approve-acct').val(bankLast4);
                  $('.approve-bank_name').val(bankName);
                  $('.acct-output').text(bankLast4);
                  $('.bank_name-output').text(bankName);
                }
                } else if (event.type === 'exception') {
                  alert(event.message);
                } else {
                  alert(event.message);
                }
          
             },{escape:true}
          );
    })
    /*Visualforce.remoting.Manager.invokeAction(
        'CreditreViewScreenController.addAssociateAccountNew', 
           parentId,
           bankIds,
           Months,         
           function(result, event) {

           },{escape:true}
      );*/
    var activeTab =$('.exists-bank-checkbox:checked').length > 1?'':'yes';
    singleBankAccountFetch(activeTab,$('.exists-bank-checkbox:checked').length);
      setTimeout(function(){
      summaryTabCalculation();
        $('#bankmodal-addaccount').modal('hide');
      },2000)
    }
}
//========================== Get bank Data Records ===================
function allExistsBankCheckbox(obj){
  $('.exists-bank-checkbox').prop('checked',$(obj).is(":checked"));
}
function checkAllChecked(){
  if($('.exists-bank-checkbox:not(:checked)').length > 0){
    $('.existsBankAllCheckbox').prop('checked',false);
  }else{
    $('.existsBankAllCheckbox').prop('checked',true);
  }
}
function getBankData(){
  $('#addBankAccount-process').hide();
  $('#addBankAccountMain').show();
  $('.bank_name,.account_number,.routing_no').val('');
  $('.new-account-range').val('6');
  $('.new-account-end_date option').prop("selected", false);
  $('.bank_name').next('font').remove();
  $('.routing_no').next('font').remove();
  $('.existingBankData').html('Processing...');
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.getBankData', 
      parentId, 
      accountId,        
         function(result, event) {
          var table ='';
          if(result.length > 0){
            table +='<div style="max-height:300px;overflow-y:auto">';
            table +='<table class="table table-striped table-bordered table-hover" id="sample_8" width="90%">';
                table +='<thead>';
                  table +='<tr>';
                    table +='<th width="7%"><input type="checkbox" class="existsBankAllCheckbox" onclick="allExistsBankCheckbox(this)" /></th>';
                    table +='<th width="65%">Name</th>';
                    table +='<th  width="28%">Account No</th>';
                  table +='</tr>';
                table +='</thead>';
                table +='<tbody>';
                for(var i =0; i<result.length;i++){
                  table +='<tr>';
                  var textColor ='';
                    if(result[i].Credit_Review_Bank_Summaries__r === undefined){
                      table +='<td><input type="checkbox" value="'+result[i].Id+'" onclick="checkAllChecked()" class="exists-bank-checkbox" /></td>';
                      textColor ='#555';
                    }else{
                      table +='<td></td>';
                      textColor ='#ccc';
                    }
                    var accNum = result[i].Account_Number__c === undefined ? 'N/A' : result[i].Account_Number__c;
                    table +='<td style="color:'+textColor+'">'+result[i].Bank_Name__c+'</td>';
                    table +='<td style="color:'+textColor+'">'+accNum+'</td>';
                  table +='</tr>';
                }
                table +='</tbody>';
              table +='</table>';
              table +='</div>';
      }else{
        table +='No Record';
      }
      $('.existingBankData').html(table);
         },{escape:true}
      );
}
$("[data-toggle='tab']").click(function(){
    if($(this).hasClass("disabled")){
      alert('Please save your changes before switching tabs. If you do not wish to save your changes, please click \'Cancel Changes\' on the bottom of this page.');
        return false;
    }
});
function decimalRegEx(obj){
  var val = obj.value;
  /*var re = /^([0-9-]+[\.]?[0-9]?[0-9]?|[0-9]+)$/g;
  var re1 = /^([0-9-]+[\.]?[0-9]?[0-9]?|[0-9]+)/g;
  if (re.test(val)) {
    } else {
      val = re1.exec(val);
      if (val) {
        obj.value.replace(/([^-\d.]+)?((,-{0,1}\d*\.?\d*)(.*)?$)/, "$3");  
        
      } else {
        obj.value = "";
      }
    }*/
    var x =obj.value;
    obj.value = x.toString().replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    val = obj.value.replace(/[^0-9\.\-\,]/g,'');
    if(val.split('.').length>2) 
      val =val.replace(/\.+$/,"");
    if(val.split('-').length>2) 
      val =val.replace(/\-+$/,"");
    obj.value = val;


  //obj.value = obj.value.replace(/([^-\d.]+)?((,-{0,1}\d*\.?\d*)(.*)?$)/, "$3");  
  if(obj.value != ""){
    if(!bankChanges){
      $('[href="#business"],[href="#guarantor"],[href="#Decision"]').addClass('disabled');
      $('.changes-btn').show(500);
      window.onbeforeunload = function() {
          return "You have unsaved changes. Are you sure you want to leave this page? All changes will be lost.";
       };
      $("[data-toggle='tab']").click(function(){
          if($(this).hasClass("disabled")){
            alert('Please save your changes before switching tabs. If you do not wish to save your changes, please click \'Cancel Changes\' on the bottom of this page.');
              return false;
          }
      });
    }
    bankChanges = true;
  }

}
//========================================== ===============
function getAccountOverViews(flag){
   var startDate = $('.startDate').val() !='' ? $('.startDate').val():'no';
   var endDate =   $('.endDate').val() != '' ? $('.endDate').val() :'no';
   var parents = [];
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.accountOverViews', 
         parentId, 
         startDate,
         endDate,   
         function(result, event) {
          var row ='';
          if(result.length > 0){
            if($('.startDate').val() ==''){
              $('.startDate').attr('value',result[0].startDate.replace(/-/g,'/'));
            } 
            if($('.endDate').val() ==''){
              $('.endDate').attr('value',result[0].endDate.replace(/-/g,'/'));
            } 
            for(var i=0; i < result.length; i++){
              var parentId = result[i].Summary.Related_Bank_Data__c;
              parents.push(parentId);
              //result[i].Column1
              //$('#'+parentId).find('.bankRow1Label').text()
          row +='<tr overview-id="'+result[i].Summary.Related_Bank_Data__c+'">';
            var accNo = result[i].Summary.Related_Bank_Data__r.Account_Number__c !== undefined ? result[i].Summary.Related_Bank_Data__r.Account_Number__c : 'N/A';
            row +='<td>'+result[i].Summary.Related_Bank_Data__r.Bank_Name__c+'</td>';
            row +='<td style="text-align:right">'+accNo+'</td>';
            row +='<td style="text-align:right"> $'+parseFloat(result[i].Column1).toFixed(2)+'</td>';
            row +='<td style="text-align:right"> '+result[i].Column2+'</td>';
            row +='<td style="text-align:right"> $'+parseFloat(result[i].Column3).toFixed(2)+'</td>';
            row +='<td style="text-align:right"> $'+parseFloat(result[i].Column4).toFixed(2)+'</td>';
            row +='<td style="text-align:right"> $'+parseFloat(result[i].Column5).toFixed(2)+' </td>';
            row +='<td style="text-align:right"> $'+parseFloat(result[i].Column6).toFixed(2)+' </td>';
            row +='<td style="text-align:right">'+result[i].Column7+'</td>';
            row +='<td style="text-align:right"> '+result[i].Column8+'</td>';
            row +='<td style="text-align:right"> $'+parseFloat(result[i].Column9).toFixed(2)+' </td>';
            
            var sel ='<select class="form-control" onchange="bankPrimary(this)" data-summary="'+result[i].Summary.Id+'" data-bank="'+result[i].Summary.Related_Bank_Data__c+'">';
            var dueSelected ='';
            var primarySelected ='';
            if(result[i].Summary.Primary_Account__c=='Primary'){
              primarySelected ='selected="selected"';
            }else if(result[i].Summary.Primary_Account__c=='Dual'){
              dueSelected ='selected="selected"';
            }
            sel +='<option value=""></option>';
            sel +='<option '+primarySelected+'>Primary</option>';
            sel +='<option '+dueSelected+'>Dual</option></select>';
            var disabledDiv = ModifyPermission == false ? '<div class="disabledByZ-index" style="display:block"></div>' :'';
            row +='<td style="position:relative">'+disabledDiv+sel+' </td>';
          row +='</tr>';
          
          
            }
            
          }else{
            row +='<center> No Record </center>';
          }
          $('#summary-tbody,#summary-tbody1').html(row);
          if(flag !== undefined){
            if(parents.length > 0){
              for(var i=0 ; i < parents.length; i++){
            allRowAvgCalculate(parents[i],'');
              }
            }
          }
          
         },{escape:true}
      );
}

function bankPrimary(obj) {
  var bankId = $(obj).attr('data-bank');
  var summaryId = $(obj).attr('data-summary');
  var type = $(obj).val();
  var bankName = $(obj).closest('tr').find('td').eq(0).text();
  var bankNo = $(obj).closest('tr').find('td').eq(1).text() !='N/A' ? $(obj).closest('tr').find('td').eq(1).text():'';
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.changeBankPrimary', 
         parentId, summaryId,type,
         function(result, event) {
          if(type == 'Primary'){
            var bankLast4 = bankNo.substring(bankNo.length-4, bankNo.length)
            $('.approve-acct').val(bankLast4);
            $('.approve-bank_name').val(bankName);
            $('.acct-output').text(bankLast4);
            $('.bank_name-output').text(bankName);
          }
          getAccountOverViews('yes');
         },{escape:true}
      );
}

// beforceunload
function inactiveChanges(){
  $('.changes-btn').hide(500);
    $('[href="#business"],[href="#guarantor"],[href="#Decision"]').removeClass('disabled');
  window.onbeforeunload = function() {
      null;
   };
  bankChanges = false;
}
function activeChanges(){
  if(!bankChanges){
    $('[href="#business"],[href="#guarantor"],[href="#Decision"]').addClass('disabled');
    $('.changes-btn').show(500);
    window.onbeforeunload = function() {
        return "You have unsaved changes. Are you sure you want to leave this page? All changes will be lost.";
     };
    $("[data-toggle='tab']").click(function(){
        if($(this).hasClass("disabled")){
          alert('Please save your changes before switching tabs. If you do not wish to save your changes, please click \'Cancel Changes\' on the bottom of this page.');
            return false;
        }
    });
  }
  bankChanges = true;
}
// Decimal Validation
function decimalValidate(){
  var topSector = $('.bankMonthSection').find('input[type=text]').not('.bankRow2,.bankRow7,.bankRow8');
  var bottomSector = $('.creditMonthSection').find('input[type=text]');
  $(topSector).keyup(function(key) {
    decimalRegEx(this); 
  });
  $(bottomSector).keyup(function(key) {
     
    decimalRegEx(this); 
  });
  $('.bankRow2,.bankRow7,.bankRow8').keyup(function(e)
  {
    var obj = $(this);
    var val = $(this).val();
    if((val[0] === '-')){
      var v ='-' + $(this).val().replace(/[^0-9]/g, '');
      $(this).val(v);
    }else{
      var v =$(this).val().replace(/[^0-9]/g, '');
      $(this).val(v);
    }

    /*var re = /^([0-9-])$/g;
      if (!re.test(this.value))
      {
          // Filter non-digits from input value.
          this.value = this.value.replace(re, '');

      }*/
      if($(this).val() !=''){
          if(!bankChanges){
        $('[href="#business"],[href="#guarantor"],[href="#Decision"]').addClass('disabled');
        $('.changes-btn').show(500);
        window.onbeforeunload = function() {
            return "You have unsaved changes. Are you sure you want to leave this page? All changes will be lost.";
         };
        $("[data-toggle='tab']").click(function(){
            if($(this).hasClass("disabled")){
              alert('Please save your changes before switching tabs. If you do not wish to save your changes, please click \'Cancel Changes\' on the bottom of this page.');
                return false;
            }
        });
      }
      bankChanges = true;
        }
  });
}
//Summary Tab
function summaryTabCalculation(){
  var months ={};
  var lastClass ='';
  var avg1=avg2=avg3=avg4=avg5=avg6=avg7=avg8=avg9=col1=col2=col3=col4=col5=col6=col7=col8=col9=avgVal1=avgVal2=avgVal3=avgVal4=avgVal5=avgVal6=avgVal7=avgVal8=avgVal9=row1=row2=row3=row4=row5=row6=row7=row8=row9=0;
  $('.bankRow1').each(function(){
    row_1=row_2=row_3=row_4=row_5=row_6=row_7=row_8=row_9=col1=col2=col3=col4=col5=col6=col7=col8=col9=0;
    var parentObj = $(this).closest('.col-md-2');
    lastClass = $(parentObj).attr("class").substr($(parentObj).attr("class").lastIndexOf(' ') + 1);
    if(months[lastClass] !== undefined){
      if($(parentObj).find('.bankMonthlyCheck').is(':checked')){
        if($(parentObj).find('.bankRow1').val() !=''){
          col1 = parseFloat($(parentObj).find('.bankRow1').val().replace(/,/g, ''))+months[lastClass].col1; 
          avg1++; 
          avgVal1 += parseFloat($(parentObj).find('.bankRow1').val().replace(/,/g, ''));
          row_1 = 1;
        }else{
          col1 = months[lastClass].col1;
          row_1 = months[lastClass].row_1;
        }
        if($(parentObj).find('.bankRow2').val() !=''){
          col2 = parseInt($(parentObj).find('.bankRow2').val())+months[lastClass].col2; 
          avg2++;
          avgVal2 += parseInt($(parentObj).find('.bankRow2').val());
          row_2 = 1;
        }else{
          col2 = months[lastClass].col2;
          row_2 = months[lastClass].row_2;
        }
        if($(parentObj).find('.bankRow3').val() !=''){
          col3 = parseFloat($(parentObj).find('.bankRow3').val().replace(/,/g, ''))+months[lastClass].col3; 
          avg3++;
          avgVal3 += parseFloat($(parentObj).find('.bankRow3').val().replace(/,/g, ''));
          row_3 = 1;
        }else{
          col3 = months[lastClass].col3;
          row_3 = months[lastClass].row_3;
        }
        if($(parentObj).find('.bankRow4').val() !=''){
          col4 = parseFloat($(parentObj).find('.bankRow4').val().replace(/,/g, ''))+months[lastClass].col4; 
          avg4++;
          avgVal4 += parseFloat($(parentObj).find('.bankRow4').val().replace(/,/g, ''));
          row_4 = 1;
        }else{
          col4 = months[lastClass].col4;
          row_4 = months[lastClass].row_4;
        }
        if($(parentObj).find('.bankRow5').val() !=''){
          col5 = parseFloat($(parentObj).find('.bankRow5').val().replace(/,/g, ''))+months[lastClass].col5; 
          avg5++;
          avgVal5 += parseFloat($(parentObj).find('.bankRow5').val().replace(/,/g, ''));
          row_5 = 1;
        }else{
          col5 = months[lastClass].col5;
          row_5 = months[lastClass].row_5;
        }
        if($(parentObj).find('.bankRow6').val() !=''){
          col6 = parseFloat($(parentObj).find('.bankRow6').val().replace(/,/g, ''))+months[lastClass].col6;  
          avg6++;
          avgVal6 += parseFloat($(parentObj).find('.bankRow6').val().replace(/,/g, ''));
          row_6 = 1;
        }else{
          col6 = months[lastClass].col6;
          row_6 = months[lastClass].row_6;
        }
        if($(parentObj).find('.bankRow7').val() !=''){
          col7 = parseInt($(parentObj).find('.bankRow7').val())+months[lastClass].col7; 
          avg7++;
          avgVal7 += parseInt($(parentObj).find('.bankRow7').val());
          row_7 = 1;
        }else{
          col7 = months[lastClass].col7;
          row_7 = months[lastClass].row_7;
        }
        if($(parentObj).find('.bankRow8').val() !=''){
          col8 = parseInt($(parentObj).find('.bankRow8').val())+months[lastClass].col8;  
          avg8++;
          avgVal8 += parseInt($(parentObj).find('.bankRow8').val());
          row_8 = 1;
        }else{
          col8 = months[lastClass].col8;
          row_8 = months[lastClass].row_8;
        }
        if($(parentObj).find('.bankRow9').val() !=''){
          col9 = parseFloat($(parentObj).find('.bankRow9').val().replace(/,/g, ''))+months[lastClass].col9;  
          avg9++;
          avgVal9 += parseFloat($(parentObj).find('.bankRow9').val().replace(/,/g, ''));
          row_9 = 1;
        }else{
          col9 = months[lastClass].col9;
          row_9 = months[lastClass].row_9;
        }
        months[lastClass] ={col1,col2,col3,col4,col5,col6,col7,col8,col9,row_1,row_2,row_3,row_4,row_5,row_6,row_7,row_8,row_9}
      }
    }else{
      if($(parentObj).find('.bankMonthlyCheck').is(':checked')){
        if($(parentObj).find('.bankRow1').val() !=''){
          col1 = parseFloat($(parentObj).find('.bankRow1').val().replace(/,/g, '')); 
          avg1++;
          avgVal1 += col1;
          row_1=1;
        }
        if($(parentObj).find('.bankRow2').val() !=''){
          col2 = parseInt($(parentObj).find('.bankRow2').val()); 
          avg2++;
          avgVal2 += col2;
          row_2=1;
        }
        if($(parentObj).find('.bankRow3').val() !=''){
          col3 = parseFloat($(parentObj).find('.bankRow3').val().replace(/,/g, '')); 
          avg3++;
          avgVal2 += col3;
          row_3=1;
        }
        if($(parentObj).find('.bankRow4').val() !=''){
          col4 = parseFloat($(parentObj).find('.bankRow4').val().replace(/,/g, '')); 
          avg4++;
          avgVal4 += col4;
          row_4=1;
        }
        if($(parentObj).find('.bankRow5').val() !=''){
          col5 = parseFloat($(parentObj).find('.bankRow5').val().replace(/,/g, '')); 
          avg5++;
          avgVal5 += col5;
          row_5=1;
        }
        if($(parentObj).find('.bankRow6').val() !=''){
          col6 = parseFloat($(parentObj).find('.bankRow6').val().replace(/,/g, ''));  
          avg6++;
          avgVal6 += col6;
          row_6=1;
        }
        if($(parentObj).find('.bankRow7').val() !=''){
          col7 = parseInt($(parentObj).find('.bankRow7').val()); 
          avg7++;
          avgVal7 += col7;
          row_7=1;
        }
        if($(parentObj).find('.bankRow8').val() !=''){
          col8 = parseInt($(parentObj).find('.bankRow8').val());  
          avg8++;
          avgVal8 += col8;
          row_8=1;
        }
        if($(parentObj).find('.bankRow9').val() !=''){
          col9 = parseFloat($(parentObj).find('.bankRow9').val().replace(/,/g, ''));  
          avg9++;
          avgVal9 += col9;
          row_9=1;
        }
        months[lastClass] ={col1,col2,col3,col4,col5,col6,col7,col8,col9,row_1,row_2,row_3,row_4,row_5,row_6,row_7,row_8,row_9}
      }
    }
    
  })
  ///alert(JSON.stringify(months));
  var summaryHeader ='<tr>';
  var summaryBody='<tr>';
  var summaryAverage1,summaryAverage2,summaryAverage3,summaryAverage4,summaryAverage5,summaryAverage6,summaryAverage7, summaryAverage8,summaryAverage9;
  summaryAverage1=summaryAverage2=summaryAverage3=summaryAverage4=summaryAverage5=summaryAverage6=summaryAverage7= summaryAverage8=summaryAverage9=0;
  for(var arrayIndex in months){
    var month_name  = arrayIndex.substr(0,3);
    var year_name = arrayIndex.substr(3,7);
    summaryHeader +='<th style="white-space: nowrap;">'+month_name+' '+year_name+'</th>';
    summaryBody +='<td>'+currencyFormat(months[arrayIndex].col1, "$")+'</td>';
    row1 += parseFloat(months[arrayIndex].row_1);
    row2 += parseFloat(months[arrayIndex].row_2);
    row3 += parseFloat(months[arrayIndex].row_3);
    row4 += parseFloat(months[arrayIndex].row_4);
    row5 += parseFloat(months[arrayIndex].row_5);
    row6 += parseFloat(months[arrayIndex].row_6);
    row7 += parseFloat(months[arrayIndex].row_7);
    row8 += parseFloat(months[arrayIndex].row_8);
    row9 += parseFloat(months[arrayIndex].row_9);
    summaryAverage1 += parseFloat(months[arrayIndex].col1);
    summaryAverage2 += parseFloat(months[arrayIndex].col2);
    summaryAverage3 += parseFloat(months[arrayIndex].col3);
    summaryAverage4 += parseFloat(months[arrayIndex].col4);
    summaryAverage5 += parseFloat(months[arrayIndex].col5);
    summaryAverage6 += parseFloat(months[arrayIndex].col6);
    summaryAverage7 += parseFloat(months[arrayIndex].col7);
    summaryAverage8 += parseFloat(months[arrayIndex].col8);
    summaryAverage9 += parseFloat(months[arrayIndex].col9);
  }
  summaryHeader +='</tr>';
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+months[arrayIndex].col2+'</td>';
  }
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+currencyFormat(months[arrayIndex].col3, "$")+'</td>';
  }
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+currencyFormat(months[arrayIndex].col4, "$")+'</td>';
  }
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+currencyFormat(months[arrayIndex].col5, "$")+'</td>';
  }
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+currencyFormat(months[arrayIndex].col6, "$")+'</td>';
  }
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+months[arrayIndex].col7+'</td>';
  }
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+months[arrayIndex].col8+'</td>';
  }
  summaryBody +='</tr><tr>';
  for(var arrayIndex in months){
    summaryBody +='<td>'+currencyFormat(months[arrayIndex].col9, "$")+'</td>';
  }
  summaryBody +='</tr>';
  // Summary Agerage
  /*var summaryAverage1,summaryAverage2,summaryAverage3,summaryAverage4,summaryAverage5,summaryAverage6,summaryAverage7, summaryAverage8,summaryAverage9;
    summaryAverage1=summaryAverage2=summaryAverage3=summaryAverage4=summaryAverage5=summaryAverage6=summaryAverage7= summaryAverage8=summaryAverage9=0;
    $('.bankRow1Label').each(function(){
      summaryAverage1 += Number($(this).text().replace(/[^0-9\.-]+/g,""));
    })
    $('.bankRow3Label').each(function(){
      summaryAverage3 += Number($(this).text().replace(/[^0-9\.-]+/g,""));
    })
    $('.bankRow4Label').each(function(){
      summaryAverage4 += Number($(this).text().replace(/[^0-9\.-]+/g,""));
    })
    $('.bankRow5Label').each(function(){
      summaryAverage5 += Number($(this).text().replace(/[^0-9\.-]+/g,""));
    })
    $('.bankRow6Label').each(function(){
      summaryAverage6 += Number($(this).text().replace(/[^0-9\.-]+/g,""));
    })
    $('.bankRow9Label').each(function(){
      summaryAverage9 += Number($(this).text().replace(/[^0-9\.-]+/g,""));
    })
    $('.bankRow2Label').each(function(){
      summaryAverage2 += Number($(this).text());
    })
    $('.bankRow7Label').each(function(){
      summaryAverage7 += Number($(this).text());
    })
    $('.bankRow8Label').each(function(){
      summaryAverage8 += Number($(this).text());
    })*/
    //alert(row1+","+row2+","+row3+","+row4+","+row5+","+row6+","+row7+","+row8+","+row9);
    //$('#summaryBody')
    //alert('&&&'+row8);

    summaryAverage1 = row1 != 0 ? summaryAverage1/row1 :summaryAverage1;
    summaryAverage2 = row2 != 0 ? summaryAverage2/row2 :summaryAverage2;
    summaryAverage3 = row3 != 0 ? summaryAverage3/row3 :summaryAverage3;
    summaryAverage4 = row4 != 0 ? summaryAverage4/row4 :summaryAverage4;
    summaryAverage5 = row5 != 0 ? summaryAverage5/row5 :summaryAverage5;
    summaryAverage6 = row6 != 0 ? summaryAverage6/row6 :summaryAverage6;
    summaryAverage7 = row7 != 0 ? summaryAverage7/row7 :summaryAverage7;
    summaryAverage8 = row8 != 0 ? summaryAverage8/row8 :summaryAverage8;
    summaryAverage9 = row9 != 0 ? summaryAverage9/row9 :summaryAverage9;

    $('.summaryLabel1').text(currencyFormat(summaryAverage1, "$"));
    $('.summaryLabel2').text(Math.round(summaryAverage2));
    $('.summaryLabel3').text(currencyFormat(summaryAverage3, "$"));
    $('.summaryLabel4').text(currencyFormat(summaryAverage4, "$"));
    $('.summaryLabel5').text(currencyFormat(summaryAverage5, "$"));
    $('.summaryLabel6').text(currencyFormat(summaryAverage6, "$"));
    $('.summaryLabel7').text(Math.round(summaryAverage7));
    $('.summaryLabel8').text(Math.round(summaryAverage8));
    $('.summaryLabel9').text(currencyFormat(summaryAverage9, "$"));

    $('#summaryHeader,#summaryHeader1').html(summaryHeader);
    $('#summaryBody,#summaryBody1').html(summaryBody);
}
function getMonthName(monthValue){
  var monthArray = {};
  monthArray['01'] = 'January';
  monthArray['02'] = 'February';
  monthArray['03'] = 'March';
  monthArray['04'] = 'April';
  monthArray['05'] = 'May';
  monthArray['06'] = 'June';
  monthArray['07'] = 'July';
  monthArray['08'] = 'August';
  monthArray['09'] = 'September';
  monthArray['10'] = 'October';
  monthArray['11'] = 'November';
  monthArray['12'] = 'December';

  return monthArray[monthValue];
}
// All Row Averages Reclaculate
function allRowAvgCalculate(parentId,className){
    //summaryTabCalculation();
    var sm = $('.startDate').val().split('/');
    var em = $('.endDate').val().split('/');
    var sDate = new Date('01 '+getMonthName(sm[1])+' '+sm[0]);
    var eDate = new Date('01 '+getMonthName(em[1])+' '+em[0]);
    for(var j =1; j < 10 ; j++){
      var row = className !='' ? className : 'bankRow'+j;
      var count,total,overviewCount,overviewTotal;
      count=total=overviewCount=overviewTotal=0;
      $('#'+parentId).find('.'+row).each(function(i){
        var check = $(this).closest('.col-md-2').find('.bankMonthlyCheck').is(":checked");
        if(check){
          var thisDate = new Date('01 '+$(this).closest('.col-md-2').find('.bank-label-head').text());
          
          if($(this).val() !=''){
            count++;
            total+=parseFloat($(this).val().replace(/,/g, ''));
            if(thisDate >= sDate && thisDate <= eDate){
              overviewCount++;
              overviewTotal +=parseFloat($(this).val().replace(/,/g, ''));
            }
          }
        }

      })
      var avg = count > 0 ? total / count : total;
      var avg1 = overviewCount > 0 ? overviewTotal / overviewCount : overviewTotal;
      var k = row.replace('bankRow','');
      k = parseInt(k)+1;
      ///alert(parentId);
      if(row == 'bankRow2' || row == 'bankRow7' || row == 'bankRow8'){
        $('#'+parentId).find('.'+row+'Label').text(Math.round(avg));
        $('#summary-tbody [overview-id="'+parentId+'"] td:eq('+k+')').text(Math.round(avg1));
        $('#summary-tbody1  [overview-id="'+parentId+'"] td:eq('+k+')').text(Math.round(avg1));
      }else{
        $('#'+parentId).find('.'+row+'Label').text(currencyFormat(avg, "$"));
        $('#summary-tbody [overview-id="'+parentId+'"] td:eq('+k+')').text(currencyFormat(avg1, "$"));
        $('#summary-tbody1 [overview-id="'+parentId+'"] td:eq('+k+')').text(currencyFormat(avg1, "$"));
      }
      if(className !='')
         break;
    }
    /*for(var k=1; k < 10; k++){
      $('[overview-id="'+parentId+'"] td:eq('+k+')').text($('#'+parentId).find('.bankRow'+k+'Label').text());
    }
    $('[overview-id="'+parentId+'"] td:eq(1)').text($('#'+parentId).find('.bankRow1Label').text());
    $('[overview-id="'+parentId+'"] td:eq(2)').text($('#'+parentId).find('.bankRow2Label').text());
    $('[overview-id="'+parentId+'"] td:eq(3)').text($('#'+parentId).find('.bankRow3Label').text());
    $('[overview-id="'+parentId+'"] td:eq(4)').text($('#'+parentId).find('.bankRow4Label').text());
    $('[overview-id="'+parentId+'"] td:eq(5)').text($('#'+parentId).find('.bankRow5Label').text());
    $('[overview-id="'+parentId+'"] td:eq(6)').text($('#'+parentId).find('.bankRow6Label').text());
    $('[overview-id="'+parentId+'"] td:eq(7)').text($('#'+parentId).find('.bankRow7Label').text());
    $('[overview-id="'+parentId+'"] td:eq(8)').text($('#'+parentId).find('.bankRow8Label').text());
    $('[overview-id="'+parentId+'"] td:eq(9)').text($('#'+parentId).find('.bankRow9Label').text()); */
    
    
}
function dailyAvg(){
  $(document).on('keyup','.month-table-bottom input',function(){
    var parentClass = $(this).closest('.col-md-2').attr('data-target');
    var parentId = $(this).closest('.tabStyle').attr('id');
    var total =0;
    var avg =0;
    $(this).closest('.col-md-2').find('input').each(function(){
      if($(this).val() !=''){
        total += parseFloat($(this).val().replace(/,/g, ''));
        avg++;
      }
    })
    if(total==0){
      total = total==0 ? '' : total;
    }else{
      total = avg==0 ? parseFloat(total).toFixed(2) : parseFloat(total/avg).toFixed(2);
    }
    if(!isNaN(total)){
      $('#'+parentId).find('.'+parentClass).find('.bankRow9').val(total);
    }
    
    
    allRowAvgCalculate(parentId,'')
  })
}
// Pull Contact
function pullContact(){
  isMonitoringRun=true;
  isBusinessMonitoringRun = {'experian' : true, 'equifax' : true} ;
  var first='null'+','+'null'+','+'null';
  var second='null'+','+'null'+','+'null';
  var last='null'+','+'null'+','+'null';
  if($(".pullSection1").css('display') == 'block' && !$(".pullSection1").hasClass('error')){
     var fid = $('.pullSection1 .title').attr('data-id') != ''?$('.pullSection1 .title').attr('data-id'):'null';
     var v1 = $('.pullOption1DependPickList').css('display') == 'block' ? $('.pullOption1Consumer').val():$('.pullSection1Select').val();
     var v2 = $('.pullOption2DependPickList').css('display') == 'block' ? $('.pullOption2Consumer').val():$('.pullSection1SelectEx').val();
      first = fid+','+v1+','+v2; 
    }
  if($(".pullSection2").css('display') == 'block' && !$(".pullSection2").hasClass('error')){
     var fid = $('.pullSection2 .title').attr('data-id') != ''?$('.pullSection2 .title').attr('data-id'):'null';
     var v3 = $('.pullOption3DependPickList').css('display') == 'block' ? $('.pullOption3Consumer').val():$('.pullSection2Select').val();
     var v4 = $('.pullOption4DependPickList').css('display') == 'block' ? $('.pullOption4Consumer').val():$('.pullSection2SelectEx').val();
      second = fid+','+v3+','+v4; 
    }
  if($(".pullSection3").css('display') == 'block' && !$(".pullSection3").hasClass('error')){
      var fid = $('.pullSection3 .title').attr('data-id') != ''?$('.pullSection3 .title').attr('data-id'):'null';
      var v5 = $('.pullOption5DependPickList').css('display') == 'block' ? $('.pullOption5Consumer').val():$('.pullSection3Select').val();
      var v6 = $('.pullOption6DependPickList').css('display') == 'block' ? $('.pullOption6Consumer').val():$('.pullSection3SelectEx').val();
      last = fid+','+v5+','+v6; 
    }
  Visualforce.remoting.Manager.invokeAction(
    
      'CreditreViewScreenController.pullContacts', 
         parentId, 
         first,
         second, 
         last,   
         function(result, event) {
            if (event.status) {
              PGCredit_toRefresh = result; // Indicates with PG Credit Info we are going to eventually refresh because it was set to Pull New or Use Most Recent
              reloadGuarantor();
              reloadGuarantorPull();   
              $('.pullOption1DependPickList,.pullOption2DependPickList,.pullOption3DependPickList,.pullOption4DependPickList,.pullOption5DependPickList,.pullOption6DependPickList').hide(); 
            } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
         

         },{escape:true}
      );
}
// Averages recalculate
function averageRecalc(){
  var topSector = $('.bankMonthSection').find('input[type=text]');
  $(topSector).blur(function(key) {
    var v = $(this).val() !='-'?$(this).val():'';
    $(this).val(v);
    var parentId = $(this).closest('.tabStyle').attr('id');
    var row = $(this).attr('class');
    allRowAvgCalculate(parentId,row);
  });
  // Checkbox
  $('.bankMonthSection').find('.bankMonthlyCheck').click(function(){
    var parentId = $(this).closest('.tabStyle').attr('id');
    allRowAvgCalculate(parentId,'');
    if(!bankChanges){
      $('[href="#business"],[href="#guarantor"],[href="#Decision"]').addClass('disabled');
      $('.changes-btn').show(500);
      window.onbeforeunload = function() {
          return "You have unsaved changes. Are you sure you want to leave this page? All changes will be lost.";
       };
      $("[data-toggle='tab']").click(function(){
          if($(this).hasClass("disabled")){
            alert('Please save your changes before switching tabs. If you do not wish to save your changes, please click \'Cancel Changes\' on the bottom of this page.');
              return false;
          }
      });
      bankChanges = true;
    }
  });

}
// Contact Consumer
function viewConsumerList(obj){
  var id = $(obj).attr('data-id');
  var label = $(obj).prev('a').text();
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.getConsumers', 
    parentId,
         id,   
         function(result, event) {
        // reloadGuarantor();
        var table ='';
        if(result.length > 0){
          table +='<table class="table table-striped table-bordered table-hover">';
                  table +='<thead>';
                    table +='<tr>';
                      table +='<th> Date </th>';
                      table +='<th> Name</th>';
                      table +='<th> Type</th>';
                      table +='<th> Score</th>';
                      table +='<th width="200" colspan="2"> Action</th>';
                    table +='</tr>';
                  table +='</thead>';
                  table +='<tbody>';
                  for(var i=0; i < result.length ;i++){
                    var fico = result[i].FICO__c !== undefined ? result[i].FICO__c : 'N/A';
                    var tDate = result[i].Transaction_Date__c !== undefined ? DateConverter(result[i].Transaction_Date__c) : 'N/A';
                    table +='<tr>';
                        table +='<td>'+tDate+'</td>';
                        table +='<td>'+result[i].Contact__r.Name+'</td>';
                        table +='<td>'+result[i].RecordType.Name+'</td>';
                        table +='<td>'+fico+'</td>';
                        var disabledDiv = ModifyPermission == false ? '<div class="disabledByZ-index" style="display:block"></div>' :'';
                        table +='<td> <a href="/'+result[i].Id+'" target="_blank">View</a> </td> <td style="position:relative;width: 150px;">'+disabledDiv;
                        if(result[i].ConsumerCreditSummaryMark__r !== undefined){
                          table +='<a href="javascript:void(0)" style="display:none" class="mark permissionDeny" onclick="insertConsumerCreditSummaryMark(\''+result[i].Id+'\',this)" role="button"> Mark as Relevant</a><a href="javascript:void(0)" class="notMark permissionDeny" onclick="removeConsumerCreditSummaryMark(\''+result[i].Id+'\',this)" role="button"> Mark as Not Relevant</a> </td>';
                        }else{
                          table +='<a href="javascript:void(0)" class="notMark permissionDeny" style="display:none" onclick="removeConsumerCreditSummaryMark(\''+result[i].Id+'\')"> Mark as Not Relevant</a><a href="javascript:void(0)" class="mark permissionDeny" onclick="insertConsumerCreditSummaryMark(\''+result[i].Id+'\',this)" role="button"> Mark as Relevant</a> </td>';
                        }
                        
                      table +='</tr>';
                  }
                  table +='</tbody>';
                table +='</table>';
        }else{
          table='<center> No Record </center>';
        }
        $('.cunsumerResult-new').html(table);
        $('.cunsumerTitle-new').text('Credit Results for '+label);
        $('#Creditresultsmodal-new').modal('show');
         },{escape:true}
      );
}
function businessCreditSummary(obj){
  var id = $(obj).attr('data-id');
  var label = $(obj).prev('a').text();
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.getBusinessCreditSummary', 
    parentId,
         id,   
         function(result, event) {
        // reloadGuarantor();
        var table ='';
        if(result.length > 0){
          table +='<table class="table table-striped table-bordered table-hover">';
                  table +='<thead>';
                    table +='<tr>';
                      table +='<th> Date </th>';
                      table +='<th> Name</th>';
                      table +='<th> Credit Bureau</th>';
                      // table +='<th> Score</th>';
                      table +='<th width="200" colspan="2"> Action</th>';
                    table +='</tr>';
                  table +='</thead>';
                  table +='<tbody>';
                  for(var i=0; i < result.length ;i++){
                    var fico = result[i].IntelliscorePlus__c !== undefined ? result[i].IntelliscorePlus__c : 'N/A';
                    var tDate = result[i].Transaction_Date__c !== undefined ? DateConverter(result[i].Transaction_Date__c) : 'N/A';
                    table +='<tr>';
                        table +='<td>'+tDate+'</td>';
                        table +='<td>'+result[i].Account__r.Name+'</td>';
                        if (result[i].hasOwnProperty('RecordType') && result[i].RecordType.Name == 'Equifax Commercial'){
                            table +='<td>Equifax</td>';
                        }else{
                            table +='<td>Experian</td>';
                        }
                        //table +='<td>'+fico+'</td>';
                        var disabledDiv = ModifyPermission == false ? '<div class="disabledByZ-index" style="display:block"></div>' :'';
                        table +='<td> <a href="/'+result[i].Id+'" target="_blank">View</a> </td> <td style="position:relative;width: 150px;">'+disabledDiv;
                        if(result[i].BusinessCreditSummaryMark__r !== undefined){
                          table +='<a href="javascript:void(0)" style="display:none" class="bussMark permissionDeny" onclick="insertBusinessCreditSummaryMark(\''+result[i].Id+'\',this)" role="button"> Mark as Relevant</a><a href="javascript:void(0)" class="bussNotMark permissionDeny" onclick="removeBusinessCreditSummaryMark(\''+result[i].Id+'\',this)" role="button"> Mark as Not Relevant</a> </td>';
                        }else{
                          table +='<a href="javascript:void(0)" style="display:none" class="bussNotMark permissionDeny" onclick="removeBusinessCreditSummaryMark(\''+result[i].Id+'\',this)" role="button"> Mark as Not Relevant</a><a href="javascript:void(0)" class="bussMark permissionDeny" onclick="insertBusinessCreditSummaryMark(\''+result[i].Id+'\',this)" role="button"> Mark as Relevant</a> </td>';
                        }

                      table +='</tr>';
                  }
                  table +='</tbody>';
                table +='</table>';
        }else{
          table='<center> No Record </center>';
        }
        $('.cunsumerResult').html(table);
        $('.cunsumerTitle').text('Credit Results for '+label);
        $('#Creditresultsmodal').modal('show');
         },{escape:true}
      );
}
// Dependent Scroller
function myScroller(obj,className){
  $(obj).scroll(function(){
        $("."+className)
            .scrollLeft($(obj).scrollLeft());
    });
    $("."+className).scroll(function(){
        $(obj)
            .scrollLeft($("."+className).scrollLeft());
    });
}
function dependentScroller(){
  //myScroller(obj,className)
  /*$(".wrapper1").scroll(function(){
        $(".wrapper2")
            .scrollLeft($(".wrapper1").scrollLeft());
    });
    $(".wrapper2").scroll(function(){
        $(".wrapper1")
            .scrollLeft($(".wrapper2").scrollLeft());
    });*/

}
// Date Range
function dateRange(){

  $('.startDate,.endDate').change(function(){
    var className = $(this).attr('class').substr($(this).attr('class').lastIndexOf(' ')+1);
    $('.'+className).val($(this).val());
    $('.loadingDiv').show();
    getAccountOverViews('yes');
    setTimeout(function(){
      $('.loadingDiv').hide(500);
    },1500);
  })
}
function pullCreditValidation(){
  // First
  if($('.equifax1_error').css('display') == 'block'){
    $('.pullSection1').show().addClass('error');
    $('.pullSection1').find('select').attr('disabled',true);
    $('.pullSection1 .error_msg').html($('.equifax1_error .error_area').html()).show();
  }else{
    if($('#signor-contact_name').val() != ''){
      $('.pullSection1').show().removeClass('error');
      $('.pullSection1').find('select').removeAttr('disabled');
      $('.pullSection1 .error_msg').hide();
    }else{
      $('.pullSection1').hide();
    }
  }
  // Second
  if($('.equifax2_error').css('display') == 'block'){
    $('.pullSection2').show().addClass('error');
    $('.pullSection2').find('select').attr('disabled',true);
    $('.pullSection2 .error_msg').html($('.equifax2_error .error_area').html()).show();
  }else{
    if($('#guarantor2-contact_name').val() != ''){
      $('.pullSection2').show().removeClass('error');
      $('.pullSection2').find('select').removeAttr('disabled');
      $('.pullSection2 .error_msg').hide();
    }else{
      $('.pullSection2').hide();
    }
  }
  // Third
  if($('.equifax3_error').css('display') == 'block'){
    $('.pullSection3').show().addClass('error');
    $('.pullSection3').find('select').attr('disabled',true);
    $('.pullSection3 .error_msg').html($('.equifax3_error .error_area').html()).show();
  }else{
    if($('#guarantor3-contact_name').val() != ''){
      $('.pullSection3').show().removeClass('error');
      $('.pullSection3').find('select').removeAttr('disabled');
      $('.pullSection3 .error_msg').hide();
    }else{
      $('.pullSection3').hide();
    }
  }
  
}

/* EXPERIAN BUSINESS CREDIT PULL */
function accountPull(obj){
  // Check if we can pull experian business credit at all
  Visualforce.remoting.Manager.invokeAction(
    'CreditReportRemoting.getExperianPermissions', 
    parentId,
    function(result, event) {
      if(!result) {
        var msg = 'Experian business credit not allowed for this deal.';
        alert(msg);
        return;
      }
      if($(obj).val() =='1'){
          childWindow = window.open("/apex/NFCreditExperianPull?reviewId="+parentId+"&acctId="+accountId, "",'width=1260px,height=600px');
          window.clearInterval(intervalID_EXP);
          intervalID_EXP = window.setInterval(checkWindow, 1000, "experian");
        }
        
        if($(obj).val() !='1' && $(obj).val() !='2'){
          Visualforce.remoting.Manager.invokeAction(
            'CreditreViewScreenController.pullBusiness', 
                 parentId, $(obj).val(), 
                 function(result, event) {
                 if (event.status) {
                  showBizCreditLoading('experian', true);
                    // $('.businessFirstLoading').show();
                    // $('.businessSecondLoading').hide();
                  callBusinessLoading('experian');
                    } else if (event.type === 'exception') {
                      alert(event.message);
                    } else {
                      alert(event.message);
                    }
                    
                 },{escape:true}
              );
        }      
    },
    { timeout: 75000 })
}
/* EQUIFAX BUSINESS CREDIT PULL */
function accountPullEquifaxComm(obj){
  if($(obj).val() =='1'){
    childWindow = window.open("/apex/NFCreditEquifaxCommPull?reviewId="+parentId+"&acctId="+accountId, "",'width=1260px,height=600px');
    window.clearInterval(intervalID_EQF);
    intervalID_EQF = window.setInterval(checkWindow, 1000, "equifax");
  }
  
  if($(obj).val() !='1' && $(obj).val() !='2'){
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.pullEFXBusiness', 
           parentId, $(obj).val(), 
           function(result, event) {
           if (event.status) {
            showBizCreditLoading('equifax', true);
              // $('.businessFirstLoading').show();
              // $('.businessSecondLoading').hide();
            callBusinessLoading('equifax');
              } else if (event.type === 'exception') {
                alert(event.message);
              } else {
                alert(event.message);
              }
              
           },{escape:true}
        );
  }
}
function callAltContact(obj,selectorId){

  if($(obj).val() == 'Use Related Contact Report'){
    $('.pullOption'+selectorId+'DependPickList').show();
    /*setTimeout(function(){
      callAltContactFill($('.pullOption'+selectorId+'Contact'),selectorId);
    },100)*/
    
      }else{
        $('.pullOption'+selectorId+'DependPickList').hide();
      }
}
function callAltContactFill(obj,selectorId){
    var id = $(obj).val();
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.CreditSummaryDependentOption', 
           id,  
           function(result, event) {
            var contactOpts = '';
            ///alert(result.consumers);
              if(result.consumers.length > 0){
                for(var i=0; i<result.consumers.length; i++){
                  contactOpts += '<option value="'+result.consumers[i].Id+'">'+result.consumers[i].Name+'</option>';
                }
              }
              $('.pullOption'+selectorId+'Consumer').html(contactOpts);
           },{escape:true}
        );
}
function completeProcessing(obj){
    showModelScoring(true); 
	$(obj).attr('disabled',true);
	$('.returnProcessing').removeClass('disabled');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.completeProcessingSave', 
           parentId, 
         function(result, event) {
			if (event.status) {
				rescoreActionFunction();
			} else if (event.type === 'exception') {
				alert(event.message);
			} else {
				alert(event.message);
			}
		}
      );
}

function returnToProcessing(obj){
  if(!$(obj).hasClass('disabled')){
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.returnProcessing', 
         parentId,  
         function(result, event) {
          setTimeout(function(){
          $(obj).addClass('disabled');
          $('.completedProcessing').removeAttr('disabled');
            $('#processing').modal('hide');
          },2000)

         },{escape:true}
      );
  }
  
}

function commercialReview(){
  $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.CommercialReviewUpdate', 
         parentId,  
         function(result, event) {
          setTimeout(function(){
          $('.reviewType').text('Commercial Review');
            $('#processing').modal('hide');
          },2000)

         },{escape:true}
      );
}
function insertBusinessCreditSummaryMark(id,obj){
    showBizCreditLoading('experian', true);
    showBizCreditLoading('equifax', true);
    $(obj).hide();
    $(obj).parent().find('.bussNotMark').show();
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.saveBusinessCreditSummaryMark', 
         parentId, 
         id, 
         function(result, event) {
      if (event.status) {
        // getBusinessCreditSummaryMark();
        fetchNotesAndAttachments(); // Refresh which reports are we using
        reloadBusinessLoader_EQF_EXP();
      } else if (event.type === 'exception') {
        alert(event.message);
      } else {
        alert(event.message);
      }
         
         //$('#Creditresultsmodal').modal('hide');
         },{escape:true}
      );
}
function removeBusinessCreditSummaryMark(id,obj){
    showBizCreditLoading('experian', true);
    showBizCreditLoading('equifax', true);
    $(obj).hide();
    $(obj).parent().find('.bussMark').show();
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.deleteBusinessCreditSummaryMark', 
         parentId, 
         id, 
         function(result, event) {
          if (event.status) {
        // getBusinessCreditSummaryMark();
        fetchNotesAndAttachments(); // Refresh which reports are we using
        reloadBusinessLoader_EQF_EXP();
      } else if (event.type === 'exception') {
        alert(event.message);
      } else {
        alert(event.message);
      }
         
        // $('#Creditresultsmodal').modal('hide');
         },{escape:true}
      );
}
function getBusinessCreditSummaryMark(){
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.fetchBusinessCreditSummary', 
         parentId, 
         'all',
         function(result, event) {
          var table='';
          if(result.length > 0){
          table +='<table class="table table-striped table-bordered table-hover">';
                  table +='<thead>';
                    table +='<tr>';
                      table +='<th> Date </th>';
                      table +='<th> Name</th>';
                      table +='<th> Credit Bureau</th>';
                      //table +='<th> Score</th>';
                      table +='<th> Action</th>';
                    table +='</tr>';
                  table +='</thead>';
                  table +='<tbody>';
                  for(var i=0; i < result.length ;i++){
                    var fico = result[i].IntelliscorePlus__c !== undefined ? result[i].IntelliscorePlus__c : 'N/A';
                    var tDate = result[i].Transaction_Date__c !== undefined ? DateConverter(result[i].Transaction_Date__c) : 'N/A';
                    table +='<tr>';
                        table +='<td>'+tDate+'</td>';
                        table +='<td>'+result[i].Account__r.Name+'</td>';
                        //table +='<td>'+fico+'</td>';
                        if (result[i].hasOwnProperty('RecordType') && result[i].RecordType.Name == 'Equifax Commercial'){
                            table +='<td>Equifax</td>';
                            table +='<td> <a href="'+result[i].Efx_Report_Link__c+'" target="_blank">View</a></td>'; 
                        }else{
                            table +='<td>Experian</td>';
                            table +='<td> <a href="'+result[i].URL_for_View_Link__c+'" target="_blank">View</a></td>';
                        }
                      table +='</tr>';
                  }
                  table +='</tbody>';
                table +='</table>';
        }else{
          table='<center> No Record </center>';
        }
        $('.relatedCorporate').html(table);
         },{escape:true}
      );
}
function insertConsumerCreditSummaryMark(id,obj){
    $(obj).hide();
    $(obj).parent().find('.notMark').show();
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.saveConsumerCreditSummaryMark', 
         parentId, 
         id, 
         function(result, event) {
          if (event.status) {
        getConsumerCreditSummary();
      } else if (event.type === 'exception') {
        alert(event.message);
      } else {
        alert(event.message);
      }
         
        // $('#Creditresultsmodal-new').modal('hide');
         },{escape:true}
      );
}
function removeConsumerCreditSummaryMark(id,obj){
    $(obj).hide();
    $(obj).parent().find('.mark').show();
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.deleteConsumerCreditSummaryMark', 
         parentId, 
         id, 
         function(result, event) {
          if (event.status) {
        getConsumerCreditSummary();
      } else if (event.type === 'exception') {
        alert(event.message);
      } else {
        alert(event.message);
      }
         
        // $('#Creditresultsmodal-new').modal('hide');
         },{escape:true}
      );
}
function getConsumerCreditSummary(){
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.fetchConsumerCreditSummary', 
         parentId, 
         function(result, event) {
          var table ='';
        if(result.length > 0){
          table +='<table class="table table-striped table-bordered table-hover">';
                  table +='<thead>';
                    table +='<tr>';
                      table +='<th> Date </th>';
                      table +='<th> Name</th>';
                      table +='<th> Type</th>';
                      table +='<th> Score</th>';
                      table +='<th> Action</th>';
                    table +='</tr>';
                  table +='</thead>';
                  table +='<tbody>';
                  for(var i=0; i < result.length ;i++){
                    var fico = result[i].FICO__c !== undefined ? result[i].FICO__c : 'N/A';
                    var tDate = result[i].Transaction_Date__c !== undefined ? DateConverter(result[i].Transaction_Date__c) : 'N/A';
                    table +='<tr>';
                        table +='<td>'+tDate+'</td>';
                        table +='<td>'+result[i].Contact__r.Name+'</td>';
                        table +='<td>'+result[i].RecordType.Name+'</td>';
                        table +='<td>'+fico+'</td>';
                        table +='<td> <a href="/'+result[i].Id+'" target="_blank">View</a></td>';
                      table +='</tr>';
                  }
                  table +='</tbody>';
                table +='</table>';
        }else{
          table='<center> No Record </center>';
        }
        $('.otherRelatedIndividual').html(table);
         },{escape:true}
      );
  
}
function saveReviewStatus(status) {
  var v1='';
  var v2='';
  var v3='';
  var v4=$('.approve-date').val() !='' && $('.approve-date').val() != null && $('.approve-date').val() != undefined ?$('.approve-date').val():'null';
  var v5=$('.approve-term').val() !='' && $('.approve-term').val() != null && $('.approve-term').val() != undefined ? $('.approve-term').val() :'null';
  var v6=$('.approve-max').val() != '' && $('.approve-max').val() != null && $('.approve-max').val() != undefined ? $('.approve-max').val() : 'null';
  // var v7=$('.approve-bofi').val() != '' ? $('.approve-bofi').val() : 'null';//todo:: olivia:: can take this out
  var v8=$('.approve-risk').is(":checked") ? 'true' :'null';
  var v9=$('.approve-sos').is(":checked") ? 'true' :'null';
  var v10=$('.approve-competitor').is(":checked") ? 'true' : 'null';
  var v11=$('.approve-ucc').is(":checked") ? 'true' : 'null';
  var v12=$('.approve-acct').val() != '' && $('.approve-acct').val() != null && $('.approve-acct').val() != undefined ? $('.approve-acct').val() : 'null';
  var v13=$('.approve-bank_name').val() != '' && $('.approve-bank_name').val() != null && $('.approve-bank_name').val() != undefined ? $('.approve-bank_name').val() : 'null';
  var v14=$('.approve-paynet').val() != '' && $('.approve-paynet').val() != null && $('.approve-paynet').val() != undefined ? $('.approve-paynet').val() : 'null';
  var coma='';
    
  console.log('all Vs: ' + v4 + ' , ' + v5 + ' , ' + v6 + ' , ' + v8 + ' , ' + v9 + ' , ' + v10 + ' , ' + v11 + ' , ' + v12 + ' , ' + v13 + ' , ' + v14);
  
  $('.PEC').each(function () {
      if($(this).is(":checked")){
        v1 +=coma+String($(this).val());
        coma=';';
      }
    })
    coma='';
    $('.AE').each(function(){
      if($(this).is(":checked")){
        v2 +=coma+String($(this).val());
        coma=';';
      }
    })
    coma='';
    $('.SMF').each(function(){
      if($(this).is(":checked")){
        v3 +=coma+String($(this).val());
        coma=';';
      }
    })
    v1 = v1 != '' ? v1 : 'null';
    v2 = v2 != '' ? v2 : 'null';
    v3 = v3 != '' ? v3 : 'null';
    var arr =[];
    arr[0]=v1;
    arr[1]=v2;
    arr[2]=v3;
    arr[3]=v4;
    arr[4]=v5;
    arr[5]=v6;
    arr[6] = null; //eventually we can remove this, no longer working with bofi 1/7/22
    arr[7]=v8;
    arr[8]=v9;
    arr[9]=v10;
    arr[10]=v11;
    arr[11]=v12;
    arr[12]=v13;
    arr[13]=v14;
    
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.saveCreditReviewStatus', 
          parentId, 
          status,
          arr,
          function(result, event) { 
            reloadRecommended();
            if (event.status) {
              if(status =='Approved'){
                    $('.approved-by').html('<a href="/'+userId+'" target="_blank">'+userFullName+'</a>');
                    var d1 = stringToDateTime(result);
                    $('.submitted-date').text(formatDate(d1, true));
              }
              if(status =='Second Review'){
                if(approvedRecomendationBy ==''){
                  $('.approvedRecommended-by').html('<a href="/'+userId+'" target="_blank">'+userFullName+'</a>');
                  var d1 = stringToDateTime(result);
                  $('.submittedRecommended-date').text(formatDate(d1, true));
                }
              }
            } else if (event.type === 'exception') {
              alert(event.message);
            } else {
              alert(event.message);
            }
           },{escape:true}
        );
        setTimeout(function(){
          disabledEvents(status);
        },3500)
        
        fillApprovelDetail();
}

function changeDecisionStatus(status){
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.changeDecisionComponentStatus', 
           parentId, 
           status,
           function(result, event) {//
            reloadRecommended();
             if(result !=''){
              //if(withdrawn_by ==''){
                $('.withdram-by').html('<a href="/'+userId+'" target="_blank">'+userFullName+'</a>');
                var d1 = stringToDateTime(result);
                $('.withdram-on').text(formatDate(d1, true));
          //}
             }
             
           },{escape:true}
        );
        setTimeout(function(){
          if(status =='Reactivated'){
            $('#firstmodel').modal('show');
            $('.reviewType').text('Initial Review');
           }

          $('#processing').modal('hide');
        },1500)
        disabledEvents(status);
}

function sendToSyndication(type){
  if($('.declineSyndicationOption:checked').length > 0 ){
    $('#processing').modal('show');
    var reason = '';
    var coma='';
    var html='';
    var br ='';
    var hasOther ='no';
    $('.declineSyndicationOption').each(function(){
      if($(this).is(":checked")){
        reason +=coma+$(this).val();
        html +=br+$(this).val();
        coma=';';
        br="<br/>";
        if($(this).val() =='Other'){
          hasOther ='yes';
        }
        
      }
    })
    var other = 'null';
    if($('.commercialOther').css('display') =='block' && $('.commercialOther input').val() != ''){
      other =$('.commercialOther input').val();

    }
    if($('.brokerOther').css('display') =='block' && $('.brokerOther input').val() != ''){
      other =$('.brokerOther input').val();
    }
    if($('.declineOther').css('display') =='block' && $('.declineOther input').val() != ''){
      other =$('.declineOther input').val();
    }
    if(other !='null' && hasOther =='yes'){
      html +=" ("+other+")";
    }
    reason = reason !='' ? reason : 'null';
    $('.syn_reason').html('');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.sendToSyndicationSave', 
      parentId, 
      reason,declineType,other,hasOther,type,
      function(result, event) {
        if(event.status) {
         if(result.success) {
            // Full success
            reloadRecommended();
            if(type =='first'){
              $('.rejected_by').html('<a href="/'+userId+'" target="_blank">'+userFullName+'</a>');
              var d1 = stringToDateTime(result.result);
              $('.rejected_on').text(formatDate(d1, true));
            }else{
              $('.approvedRecommended-by').html('<a href="/'+userId+'" target="_blank">'+userFullName+'</a>');
              var d1 = stringToDateTime(result.result);
              $('.submittedRecommended-date').text(formatDate(d1, true));
            }
            $('.syn_reason').html(html);
            setTimeout(function(){
              $('#processing').modal('hide');
            },1500)
          } else {
            // Application level error occured
            alert(result.errorMessage);
			$('.top-decision').hide();
			$('.main-decision-box').hide();	
			$('.top-decision-'+'div14').show()
			$('#processing').modal('hide');
          }
        } else {
          // Unhandled error resulting in an exception
          alert(event.message);
		  $('.top-decision').hide();
		  $('.main-decision-box').hide();
		  $('.top-decision-'+'div14').show()
		  $('#processing').modal('hide');
        }
      },{escape:true}
      );
  }
}


function tierDeclineSave(type){
  $('#processing').modal('show');
  var reason = '';
  var coma='';
  var html='';
  /*$('.declineSyndicationOpt').each(function(){
    if($(this).is(":checked")){
      reason +=coma+$(this).val();
      html +="<br/>"+$(this).val();
      coma=';';
    }
    
  })*/
  reason = reason !='' ? reason : 'null';
  Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.tierDeclineRecordSave', 
           parentId,
           type, 
           reason,
           declineType,
           function(result, event) {
            reloadRecommended();
            if (event.status) {
          $('.reviewType').text(type+' Review');
              if(type != 'Commercial'){
                $('.updateCommercialBtn,.normal-approve').show();
                $('.validate-approve,.FinancialAnalysis_UWCall').hide()
              }else{
                declineType ='Commercial';
                refreshDecision();
                $('.normal-approve').hide();
                $('.FinancialAnalysis_UWCall,.validate-approve').show()
              }
        } else if (event.type === 'exception') {
          alert(event.message);
        } else {
          alert(event.message);
        }
            
           },{escape:true}
        );
  setTimeout(function(){
    $('#processing').modal('hide');
  },1500)
}
function recoreEdit(){
  $('#rescore_button').hide().prop('disabled', true);
  $('#scoring_button').show().addClass('active');
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.recoreUpdate', 
         parentId, 
         function(result, event) {
         if (event.status) {
          rescoreActionFunction();
        } else if (event.type === 'exception') {
           alert(event.message);
        } else {
          alert(event.message);
        }
         decisionMonitoringLoading();
 
        // Deal with refreshes on starter loan program
        refreshOnStarterLoan(result);

         setTimeout(function(){
             $('#scoring_button').hide()
             $('#rescore_button').show().prop('disabled', false);
          
         },1500)
		 // get element for score refreshed time display
		 var refreshedDiv = document.getElementById("lastRefreshedTime");
		 // set the last refreshed time
		 var nowDate = new Date();
		 nowDate = nowDate.toLocaleString();
		 refreshedDiv.innerHTML = '<span class="light-green-color" style="font-size: 11px;"><i>Last scored ' + nowDate + '</i></span>';
         },{escape:true}
      );
}
//==================================== Saving Contact================================================
function saveNewContact(){
  var firstname = $('.con-firstname').val() !='' ? $('.con-firstname').val() :'null';
  var lastname = $('.con-lastname').val() !='' ? $('.con-lastname').val() :'null';
  var ssn_encrpted = $('.con-ssn-encrpted').val() !='' ? $('.con-ssn-encrpted').val() :'null';
  var ownership_percentage = $('.con-ownership-percentage').val() !='' ? $('.con-ownership-percentage').val() :'null';
  var title = $('.con-title').val() !='' ? $('.con-title').val() :'null';
  var phone = $('.con-phone').val() !='' ? $('.con-phone').val() :'null';
  var area = $('.area').val();
  var error='';
  if(lastname =='null'){
    error +='Last Name is Required!\n';
  }
  if(ownership_percentage != 'null'){
    if(parseInt(ownership_percentage) > 100){
      error +=' Max Ownership Percentage 100\n';
    }
  }
  if(error == ''){
    $('.loadingDiv').show();
    Visualforce.remoting.Manager.invokeAction(
     'CreditreViewScreenController.createContact',  
     accountId,
     firstname,
     lastname,
     ssn_encrpted,
     ownership_percentage,
     title,
     phone,
     function(result, event) {
      if (event.status) {
        var fieldName = area == 'signor' ? 'PG1__c' : (area == 'guarantor2' ? 'PG2__c' : 'PG3__c');
        var pgNo  = area == 'signor' ? '1' : (area == 'guarantor2' ? '2' : '3');
        var secondId  = area == 'signor' ? '1' : (area == 'guarantor2' ? 'gua2' : 'gua3');
        //var obj = $('.guarantor2-radio:checked');
              $('#'+area+'-contact_id').val(result);
              $('#'+area+'-contact_name').val(firstname+' '+lastname);
              addRemoveButton(area+'-contact_name',fieldName,secondId);
              $('#'+area+'-ownership').val(ownership_percentage); 
              $('#'+area+'-contact_ssn').val(ssn_encrpted);
              // $('#'+area+'-modal').modal('hide');
              $('#'+secondId+',#'+area+'-ownership').removeAttr('disabled');

              if(pullCreditPermission =='true')
                 $('.pull'+pgNo).removeAttr('disabled'); 
              callSaveGuarantorInfo(result,pgNo); 
              getGuarantorInfo();

              setTimeout(function(){
                $('.loadingDiv').hide();
                  $('#newcontact').modal('hide')
              },2500)
        
            } else if (event.type === 'exception') {
              alert(event.message);
              $('.loadingDiv').hide();
            } else {
              alert(event.message);
              $('.loadingDiv').hide();
            }
    }     
   ); 
  }else{
    alert(error);
  }
  
}
function getHistories(){
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.getHistory', 
         parentId, 
         function(result, event) {
         var table ='';
         if(result.length > 0){
          table +='<table class="table" id="histories_modal" width="90%" >';
              table +='<thead>';
                table +='<tr>';
                  table +='<th>Link</th>';
                  table +='<th>Recommendation</th>';
                  table +='<th>Created Date</th>';
                table +='</tr>';
              table +='</thead>';
              table +='<tbody>';
              for(var i=0;i<result.length;i++){
				console.log('>>>> result[' + i + ']: ' + result[i].WC_Credit_Decision_Bin__c);
                var date = timeConverter(result[i].CreatedDate);
                table +='<tr>';
                  var WC_Decision_Recommendation = result[i].WC_Decision_Recommendation__c !== undefined ?result[i].WC_Decision_Recommendation__c:'N/A';
                  var WC_DecisionBin = result[i].WC_Credit_Decision_Bin__c === undefined ? 'N/A' : result[i].WC_Credit_Decision_Bin__c;
                  table +='<td><a onclick="window.open(\'/'+result[i].Id+'\',\'\',\'width=1260px,height=600px\')">'+result[i].Name+'</a></td>';
                  table +='<td>'+WC_Decision_Recommendation+'</td>';
                  table +='<td>'+timeConverter(result[i].CreatedDate)+'</td>';
                table +='</tr>';
              }
                
              table +='</tbody>';
            table +='</table>';
         }else{
          table ='<p align="center">There are no previous history records.</p>';
         }
         $('#recommendation-history').html(table);
         },{escape:true}
      );
}
function checkMaxApprove(obj) {
  var val = obj.value;
  var re = /^([0-9]+[\.]?[0-9]?[0-9]?|[0-9]+)$/g;
  var re1 = /^([0-9]+[\.]?[0-9]?[0-9]?|[0-9]+)/g;
  if (re.test(val)) {
  } else {
    val = re1.exec(val);
    if (val) {
      obj.value = val[0];
    } else {
      obj.value = "";
    }
  }

  if ($(obj).val() != '') {
    if(parseFloat($(obj).val()) > parseFloat(userMaxApproval) ){
        $('.Approve').not('.businessLoanApproval').not('.noDesabled').attr('disabled','disabled');
    } else {
        $('.Approve').not('.businessLoanApproval').not('.notPermission').removeAttr('disabled');
    }
  }
}

function consumerMonitoringLoading(type,onload){
  try {
      if(isMonitoringRun){
      Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.consumersMonitoring', 
           parentId,
           PGCredit_toRefresh,
           function(result, event) {
            if (event.status) {
              var count = parseInt(result);
              if(count < 1){
                  // There are no more consumer credit summary credit pulls we are monitoring
                isMonitoringRun=false; 
                window.clearInterval(consumer2Interval);
                consumer2Interval = 0;
                if(onload != 'yes')
                  reloadGuarantorLoader();
                // We are done pulling credit. Update the creditReview object and re-render the PG credit tab
                // By now, in the CreditreViewScreenController.consumersMonitoring, we should have already
                // updated the actual Credit_Review__c record itself
                updatePGCredit();

                // Go back to not refreshing stuff
                PGCredit_toRefresh = {
                          'PG1_EXP' : false, 
                          'PG1_EQF' : false, 
                          'PG2_EXP' : false, 
                          'PG2_EQF' : false, 
                          'PG3_EXP' : false, 
                          'PG3_EQF' : false
                };
              }else{
                reloadGuarantorLoader();
              }
            }
            
           },{buffer: true, escape: true, timeout: 120000 , maxretries: 2}
        );
    }
  }
  catch(err) {
      //document.getElementById("demo").innerHTML = err.message;
  }
  
}

function businessMonitoringLoading(bureau){
  try {
    if (bureau == 'equifax') {
      method = 'businessMonitoring';  // For now
    } else {
      method = 'businessMonitoring';
    }
    if(isBusinessMonitoringRun[bureau]){
      Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.' + method, 
           parentId,
           bureau,
           (function(obj){
              return function(result, event) {
                if(result != '0'){ 
                   // There are still some business credit reports processing ... check again in a few seconds
              }else{
                if(stopReload == false){
                  if (obj == "equifax") {
                    reloadBusinessLoader_EQF();
                  } else {
                    reloadBusinessLoader();
                  }
                }
                else{
                  if (obj == "equifax") {
                    reloadBusinessLoaderRight_EQF();
                  } else {
                    reloadBusinessLoaderRight();
                  }
                }
                fetchNotesAndAttachments();
                //reloadGuarantorPull();
                isBusinessMonitoringRun[obj] = false;
              }
             }
           }(bureau))
           ,{buffer: true, escape: true, timeout: 120000 , maxretries: 2}
        );
    }
  }
  catch(err) {
  }
  
    
}
function savePgCreditResult(className){
$('#processing').modal('show');
  var values = [];
  for(var i=1;i < 8; i++){
    //alert($('.'+className+'Guarantor'+i).val())
    var value = $('.'+className+'Guarantor'+i).val() != '' ? $('.'+className+'Guarantor'+i).val() : 'null';
    //alert(value)
    if(i==6 || i==7){
      if(value != 'null')
        value = value.replace(/[^0-9]/g, '');
    }
    values.push(value);
  }
    Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.savePgCreditResults', 
         parentId,
         values,
         className,
         function(result, event) {
          if (event.status) {
			// Refresh the view state
			refreshViewState();
      } else if (event.type === 'exception') {
        alert(event.message);
      } else {
        alert(event.message);
      }
         // Geting Unbind Datepicker
         ///  reloadGuarantor();
         },{buffer: true, escape: true, timeout: 120000 , maxretries: 2}
      );
      setTimeout(function(){
          $('#processing').modal('hide');
         },1500)
}
function callConsumerLoading(onload){
  consumer2Interval = setInterval(function(){
    var onloadValue = onload !== undefined ? 'yes' : 'no';
    consumerMonitoringLoading('consumer1',onloadValue);
  }, 1000);
  setTimeout(function(){
      window.clearInterval(consumer2Interval);
      $('div[class$="loading-icon"][style*="display:block"]').html("We're still waiting for a response from the credit bureau. Please refresh to check status. If this is not the first time you've received this message, please notify your Salesforce administrator.");
      consumer2Interval = 0;
  },60000);
  
}
function callBusinessLoading(bureau){
  //reloadBusinessReLoaderRight(); --> Not sure why this is here or was commented out when I got here! Igor
  if(typeof(bizMonitorIntervalID[bureau]) != "undefined") {
    // Clear any existing interval before we start a new one
    window.clearInterval(bizMonitorIntervalID[bureau]);
    bizMonitorIntervalID[bureau] = 0;
  }

  // Create an interval to poll every 2 seconds for this biz bureau
  bizMonitorIntervalID[bureau] = setInterval(
                                (function(obj){
                                        // the closure
                                        return function () {
                                            businessMonitoringLoading(obj);
                                        };
                                    }(bureau)),
                                    2000);
  setTimeout(
    (function(obj){
      // the closure
      return function () {
        window.clearInterval(bizMonitorIntervalID[obj]);
        bizMonitorIntervalID[obj] = 0;
      if (isBusinessMonitoringRun[obj]) {
        $('.business-loading-icon').html("We're still waiting for a response from the credit bureau. Please refresh to check status. If this is not the first time you've received this message, please notify your Salesforce administrator.");
      }
     };
    }(bureau)),
    75000);
}
function isSICNull(){
    $('#processing').modal('show');
    Visualforce.remoting.Manager.invokeAction(
      'CreditreViewScreenController.checkSICconde',
       parentId,     
         function(result, event) {
          if(result == 'yes'){
            $('.sic-none').show();
            $('.sic-block').hide()
          }
          
         },{escape:true}
      );
     setTimeout(function(){
    $('#processing').modal('hide');       
     },2000) 
  
 }
function clearBusinessLoading(bureau){
  window.clearInterval(bizMonitorIntervalID[bureau]);
  bizMonitorIntervalID[bureau] = 0;
}

function clearBothInterval(){
  $('div[class$="business-loading-icon-experian"][style*="display:block"]').html("We're still waiting for a response from the credit bureau. Please refresh to check status. If this is not the first time you've received this message, please notify your Salesforce administrator.");
  $('div[class$="business-loading-icon-equifax"][style*="display:block"]').html("We're still waiting for a response from the credit bureau. Please refresh to check status. If this is not the first time you've received this message, please notify your Salesforce administrator.");
  clearBusinessLoading("equifax");
  clearBusinessLoading("experian");
  window.clearInterval(consumer2Interval);
  consumer2Interval = 0;
}

function fillApprovelDetail(){  
  var v1='';
  var v2='';
  var v3='';
  $('.PEC').each(function(){
    if($(this).is(":checked")){
      v1 +=$(this).val()+'<br/>';
    }
  })
  v1 = v1 !='' ? v1 : '<p style="color:#888">Not Applicable</p>';
  $('.policyExceptions').html(v1);
  $('.AE').each(function(){
    if($(this).is(":checked")){
      v2 +=$(this).val()+'<br/>';
    }
  })
  v2 = v2 !='' ? v2 : '<p style="color:#888">Not Applicable</p>';
  $('.allowableExceptions').html(v2);
  $('.SMF').each(function(){
    if($(this).is(":checked")){
      v3 +=$(this).val()+'<br/>';
    }
  })
  v3 = v3 !='' ? v3 : '<p style="color:#888">Not Applicable</p>';
  $('.strongMitigatingFactors').html(v3);
  var v4 = $('.approve-date').val() !='' ? $('.approve-date').val() : '<p style="color:#888">Not Applicable</p>';
  $('.approvalDateView').html(v4)
  var v5 = $('.approve-term').val() !='' ? $('.approve-term').val() : '<p style="color:#888">Not Applicable</p>';
  $('.maxTermView').html(v5)
  var v6 = $('.approve-max').val() !='' ? '$'+$('.approve-max').val() : '<p style="color:#888">Not Applicable</p>';
  $('.maxApprovalView').html(v6)
  var v7 = $('.approve-bofi').val() !='' ? $('.approve-bofi').val() : '<p style="color:#888">Not Applicable</p>';
  $('.boriView').html(v7+'<br/>');
  var v8 = $('.approve-risk').is(":checked") ? 'Yes' : 'No';
  $('.risk-output').html(v8+'<br/>');
  var v9 = $('.approve-sos').is(":checked") ? 'Yes' : 'No';
  $('.sos-output').html(v9+'<br/>');
  var v10 = $('.approve-competitor').is(":checked") ? 'Yes' : 'No';
  $('.competitor-output').html(v10+'<br/>');
  var v11 = $('.approve-ucc').is(":checked") ? 'Yes' : 'No';
  $('.ucc-output').html(v11+'<br/>');
  var v12 = $('.approve-acct').val() !='' ? $('.approve-acct').val() : '<p style="color:#888">Not Applicable</p>';
  $('.acct-output').html(v12);
  var v13 = $('.approve-bank_name').val() !='' ? $('.approve-bank_name').val() : '<p style="color:#888">Not Applicable</p>';
  $('.bank_name-output').html(v13);
  var v14 = $('.approve-paynet').val() != '' ? $('.approve-paynet').val() : '<p style="color:#888">Not Applicable</p>';
  $('.paynet-output').html(v14);  
}

function checkWindow(bureau) {
    if (childWindow && childWindow.closed) {
      if (bureau == "equifax") {
        window.clearInterval(intervalID_EQF);
        intervalID_EQF=0;
      } else {
        window.clearInterval(intervalID_EXP);
        intervalID_EXP=0;
      }
      showBizCreditLoading(bureau, true);
      isBusinessMonitoringRun[bureau] = true;
      callBusinessLoading(bureau);
  }
}

function onlyInteger(){
  $('.onlyInteger').keyup(function(){
    var obj = $(this);
    var val = $(this).val();
    if((val[0] === '-')){
      var v ='-' + $(this).val().replace(/[^0-9]/g, '');
      $(this).val(v);
    }else{
      var v =$(this).val().replace(/[^0-9]/g, '');
      $(this).val(v);
    }
  })
  
}
function stopToClearValue(){
  $('.business-info').find('input[type=text]').keyup(function(){
    stopReload = true;
  })
  $('.business-info').change(function(){
    stopReload = true;
  })
}
function unbindStopToClearValue(){
  stopReload = false;
}
function rebindDateFields(){
  $('.dateInput input[type=text]').datepicker();
}
function declineOtherCheckbox(){
  $('.declineSyndicationOption').click(function(){
    if($(this).val() =='Other'){
      if($(this).is(":checked")){
        $('.brokerOther,.declineOther,.commercialOther').hide()
        if(declineType =='Commercial'){
          $('.commercialOther').show();
        }
        if(declineType =='Broker'){
          $('.brokerOther').show();
        }
        if(declineType =='Decline'){
          $('.declineOther').show();
        }
      }else{
        $('.brokerOther,.declineOther,.commercialOther').hide()
      }
    }
  })
}
$(document).ready(function() {
 // $(document).on('keypress keydown','.pg1Guarantor2,.pg2Guarantor2,.pg3Guarantor2,.approve-date',function(e) {
  $(document).on('keypress keydown','.approve-date',function(e) {
  if (event.keyCode == 9) {
      return true;
  }
  if (event.keyCode == 8 || event.keyCode == 46) {
      return false;
  }
 
 return false;
});
declineOtherCheckbox();
onlyInteger();
stopToClearValue();
if(pullCreditPermission =='false'){
  $('button,a').filter(function(){
     return $(this).text() === "Pull Credit";
  }).attr('disabled','disabled');
}
if(userId == approvedRecomendationBy){
  $('#decision-approve2').not('.noDesabled').addClass('notPermission').attr('disabled','disabled');
}
// Show First Modal
if(creditReviewType =='Initial Review'){
  $('#firstmodel').modal({backdrop: 'static', keyboard: false});
}
fillApprove();
$('.integer').keyup(function(){
  if (/\D/g.test(this.value))
      {
          // Filter non-digits from input value.
          this.value = this.value.replace(/\D/g, '');

      }
})

$( ".startDate, .endDate" ).datepicker({
  "format": "yyyy/mm",
  viewMode: "months", 
  minViewMode: "months"
}).on('changeMonth', function(e) {
  var dp = $(e.currentTarget).data('datepicker');
  dp.date = e.date;
  dp.setValue();
  dp.hide();
})
$('.dateOnlyInput input').datepicker({
  "format": "mm/dd/yyyy",
  "autoclose":true
  })
  callJson('');
// Average Recalculate
averageRecalc();
// Call Decimal Validation
decimalValidate();
// Top Buttom Scroller Dependent
dependentScroller();

dateRange();


getAccountOverViews();

//fillSSNLookupRecord();

getGuarantorInfo();

disabledEvents(creditReviewStatus);

dailyAvg();

getBusinessCreditSummaryMark();
getConsumerCreditSummary();

// Make sure we disable the approve button if the max approval amount has been set somehow to be too big
checkMaxApprove($('.approve-max')[0]);

// Don't do this on page loading
// callBusinessLoading('experian');
// callBusinessLoading('equifax');

callConsumerLoading('first');

declineChecked();
// Landing Tab
if(decitionTab == 'true'){
  $('[href="#Decision"]').click();
}
//====================== Platinum Review Decision Start ==================================
  $('.main-decision-call').click(function(e){
        e.preventDefault();
        $('.top-decision').hide();
        $('.main-decision-box').show();
    })
  $('.div1,.div2,.div3,.div4,.div5,.div6,.div7,.div8,.div9,.div14,.div15,.div16,.div17,.div20').click(function (e) {
    var classStr = $(this).attr('class');
    e.preventDefault();
    if (classStr == 'Tier div8' || classStr == 'Syndication div14') {
      Visualforce.remoting.Manager.invokeAction(
        'CreditreViewScreenController.checkCRDeclinePermissions',
        function (result, event) {
          if (result == 'yes') {//user can not decline CRs
            alert('You do not have permission to decline a Credit Review');
          } else {
            allCrActions();
          } 
        }, { escape: true });
    } else {
      allCrActions();
    }
    
    function allCrActions() {
      if ($(this).hasClass('first-approve') || $(this).hasClass('second-approve')) {
          
        var error = '';
        if ($('.approve-date').val() == '') {
          error += 'Please Fill "Date of approval Expiration"\n';
        }
        if ($('.approve-term').val() == '') {
          error += 'Please Fill "Max Approval"\n';
        }
        if ($('.approve-max').val() == '') {
          error += 'Please Fill "Max Term"\n';
        }
        if ($('.approve-bofi').val() == '') {
          error += 'Please Fill "BOFI"\n';
        }
        if (error != '') {
          alert(error);
          return false;
        }
      }
      if ($(this).hasClass('validate-approve-btn')) {
        var error = '';
        if (!$('.FinancialAnalysis').is(":checked")) {
          error += 'Please Fill "Financial Analysis"\n';
        }
        if (!$('.UWCall').is(":checked")) {
          error += 'Please Fill "UW Call"\n';
        }
        if (error != '') {
          alert(error);
          return false;
        }
      }
      if ($(this).hasClass('syndication-send')) {
        if ($('.declineSyndicationOption:checked').length < 1) {
          alert('Please Select Decline Reason');
          return false;
        }
      }
      $('.top-decision').hide();
      $('.main-decision-box').hide();
      // var classStr = $(this).attr('class');
      var lastClass = classStr.substr(classStr.lastIndexOf(' ') + 1);
      $('.top-decision-' + lastClass).show();
      if (lastClass == 'div8' || lastClass == 'div20' || lastClass == 'div17') {
        $('.Platinum-box,.Diamond-box,.Gold-box').show();
        if ($('.reviewType').eq(0).text() == 'Platinum Review')
          $('.Platinum-box').hide();
        if ($('.reviewType').eq(0).text() == 'Diamond Review')
          $('.Diamond-box').hide();
        if ($('.reviewType').eq(0).text() == 'Gold Review')
          $('.Gold-box').hide();
      }
      if ($(this).attr('class').indexOf('changeApproval') != -1) {
        setTimeout(function () {
          if ($('.first-approve').hasClass('secondApporveChange')) {
            $('.first-approve').show();
            $('.second-approve').hide();
          } else {
            $('.first-approve').hide();
            $('.second-approve').show();
          }
        }, 151)
        if ($(this).hasClass('secondApproveChanage')) {
          $('.secondReview,.go-back1,.go-back2,.go-back4').hide();
          $('.go-back3').show();
        } else {
          $('.secondReview,.go-back1,.go-back3,.go-back4').hide();
          $('.go-back2').show();
        }
          
      } else {
        $('.secondReview,.go-back1,.first-approve').show();
        $('.go-back2,.go-back3,.second-approve,.go-back4').hide();
        if ($(this).hasClass('secondReviewDecline')) {
          $('.go-back1,.go-back2,.go-back3').hide();
          $('.go-back4').show();
        }
      }
      if ($(this).hasClass('syndication-approve')) {
        $('.div14first').hide();
        $('.div14second').show();
      } else {
        $('.div14second').hide();
        $('.div14first').show();
      }
    }

    })
  $('.showButton').click(function (e) {
    console.log('what is e ' + e);
       e.preventDefault(); 
    }) 
//====================== Platinum Review Decision End ==================================
  // Redirect Page
    $(".change_stripulations").click(function(){
        setCookie("stripulations",'yes', 30);
        //window.location.href="/apex/checklist";
        window.open("/apex/checklist?id="+parentId, "",'width='+w+'px,height='+h+'px');
    })
  //Disabled Business Information
  // $('.disabled').attr('disabled',true);

  //============ On Enter Hit Call Searching==================
  $('#searchfield').keypress(function(key) {
      if(key.charCode == 13 ){
          $('#searchagain').click();
      }
  });
  //================== On Enter Hit Call Searching==================
  $('#searchAgainTextBox').keypress(function(key) {
      if(key.charCode == 13 ){
          $('#save_search_again').click();
      }
  });
  $('[id$=clearresults]').css("display","none");

  // =================Business Search Start===============================
  $('[id$=searchagain]').click(function(){
      if($('[id$=searchfield]').val().length < 3){
          $('[id$=searchfield]').next().remove('font');
          $('[id$=searchfield]').next().remove('br');
          $('[id$=searchfield]').after('<font color="red" class="error-tag">You must search for a minimum of 2 characters.</font><br/>');
      }else{
          $('[id$=searchfield]').next().remove('br');
          $('[id$=searchfield]').next().remove('font');
          ///business_search();               
          $('.searchvalue').val($('[id$=searchfield]').val());
          $('.searchvalue').text($('[id$=searchfield]').val());
          $('[id$=main-search]').hide();
          $('[id$=search-process]').show();
          setTimeout(function(){
              $('[id$=search-process]').hide();
              $('.query').show();
              $('.bottom-button2').show();
              $('.bottom-button1').hide();
              
          },2000);
      }
  })

  $('#add_and_save').click(function(){
      saveFunctionCall();
   });
        
  $('[id$=save_search_again]').click(function(){
      if($('[id$=searchAgainTextBox]').val().length > 3)
      rebindProcessingBox();
      saveFunctionCall();
  });
  $('[id$=searchAgain]').click(function(){
      if($('[id$=searchAgainTextBox]').val().length > 3)
      rebindProcessingBox()
  });
  // =================Business Search End==========================

  $('a[id$=showhidetrigger]').click(function() {
      $('[id$=clearresults]').css("display","inline-block");
      $('[id$=searchagain]').css("display","inline-block");
  });

  //clear search field on button click
  $("[id$=clearresults]").click(function() {
      $("[id$=searchfield]").val("");
      $('[id$=sample_8]').css("display","none");
  });

  //Search Again
  $("[id$=searchagain]").click(function() {
      $('[id$=sample_8]').css("display","inline-table");
  });
  $('.toggle').click(function (event) {
      event.preventDefault();
      var target = $(this).attr('href');
      $(target).toggleClass('hidden show');
  });
  $('.collepse-bar .expand-btn').on('click', function(e) {
      e.preventDefault();
      var $this = $(this);
      $this.find('i').toggleClass('fa-minus-circle');
      var $collapse = $this.closest('.collapse-group').find('.collapse');
      $collapse.toggle(500);
     fetchNotesAndAttachments();
      
  });
  /*if(businessEditPermission =='false'){
    $('.bussInfodisabled').attr('disabled',true);
  }*/
  setTimeout(function(){
    pullCreditValidation();
    if(creditReviewStatus =='Approved'){
      $('.approved-status').click();
    }
    if(creditReviewStatus =='Second Review' && secondReviewFrom == 'Approval'){
      $('.first-approve').attr('class','secondApporveChange mt10 first-approve Approve div3');
      $('.secondReview-status').click();
    }
    if(creditReviewStatus =='Second Review' && secondReviewFrom == 'Syndication'){
      $('.secondReviewNew-status').click();
    }
    if(creditReviewStatus =='Withdrawn'){
      $('.withdrawn-status').click();
    }
    if(creditReviewStatus =='Declined' || creditReviewStatus =='NF Decline'){
      $('.Declined-status').click();
    }
  },1000)
  // Return to first-approve
  $('#decision-approve2').click(function(){
    $('#decision-approve').show().attr('class','secondApporveChange mt10 first-approve Approve div3');  
    $('.second-approve-back').show();
    $('.approve-back').hide();
  })
  $('#decision-update,.changeApproval').click(function(){
    $('#decision-approve').show().attr('class','secondApporveChange mt10 first-approve Approve div3');  
  })
  $('.first-approve,.second-approve').click(function(){
    $('.second-approve-back').hide();
    $('.approve-back').show();
  })
  $('.changeApproval-first').click(function(){
    $('.second-approve').attr('class','mt10 second-approve Approve noDesabled div4').removeAttr('onclick');
  })
  $('.secondReview ').click(function(){
    $('#decision-approve2').attr('disabled',true);
  })
  $('.div8').click(function (e) {
      $('.declineOpt').prop('checked',false);
  })
});



//====================== Display results of a related contacts search =======================================
function callContactSSNSearch(contact_id){   
    Visualforce.remoting.Manager.invokeAction(
     'CreditreViewScreenController.searchContactSSN', 
         parentId, contact_id,
         function(result, event) {
         if(result.length > 0){
            var table='<div style="max-height:350px;overflow-y:scroll"><table class="table table-striped table-bordered table-hover">';
              table+='<thead>';
                table+='<tr>';
                  table+='<th>#</th>';
                  table+='<th>Name</th>';
                  table+='<th>Title</th>';
                  table+='<th>Account</th>';
                table+='</tr>';
              table+='</thead>';
              table+='<tbody>';
              for(var index=0;index < result.length; index++){
                var title = result[index].Title !== undefined ?result[index].Title:'N/A';
                table+='<tr>';
                  table+='<td><input class="gurantor-ssn-checkbox" checked="checked" type="checkbox" value="'+result[index].Id+'"  /></td>';
                    table+='<td>'+result[index].Name+' <a href="/'+result[index].Id+'" target="_blank">(View Record)</a></td>';
                  table+='<td>'+title+'</td>';
                  table+='<td>'+result[index].Account.Name+'</td>';
                table+='</tr>';
              }
              table+='</tbody>';
            table+='</table></div>';
            $('#ssnresultsBox').html(table);
            $('#ssnloader,.bottom-button1').hide();
            $('#ssnresults,.bottom-button2').show();
        
            }else{
               $('#ssnloader').show();
            setTimeout(function(){
                  $('#ssnloader,.bottom-button1,.associate-btn').hide();
              $('#ssnresultsBox').html('<br/><center>No Record Found<center>');
                  $('#ssnresults,.bottom-button2').show();
            },500)
            }
         },{escape:true}
     )
}
//====================== Fetch  SSN Search Record End =======================================
function searchContactSSN(callFrom, contact_id){
  var contactName = $(callFrom).closest('fieldset').find('[id$="contact_name"]').val();
    callFromObj = callFrom;// Call From Object
    if(contact_id ==''){
      $('#ssnloader').show();
      $('.searchingOf').text(contactName);
      setTimeout(function(){
        $('#ssnloader,.bottom-button1,.associate-btn').hide();
        $('#ssnresultsBox').html('<br/><center>The SSN for this contact has not been provided.<center>');
            $('#ssnresults,.bottom-button2').show();
            if($(callFromObj).has( "i" ).length > 0 ){
          $('#ssn_complete').attr('checked','checked');
        }else{
          $('#ssn_complete').removeAttr('checked');
        }
      },1000)
         
    }else{
      $('#ssnloader').show();
      $('.searchingOf').text(contactName);
      if($(callFromObj).has( "i" ).length > 0 ){
        $('#ssn_complete').attr('checked','checked');
      }else{
        $('#ssn_complete').removeAttr('checked');
      }

    callContactSSNSearch(contact_id);
    }
    
}

 function decisionMonitoringLoading(){
   try {
       Visualforce.remoting.Manager.invokeAction(
       'CreditreViewScreenController.decisionRecordMonitoring', 
            parentId,
            function(result, event) {
             if(result == 'yes') { 
               // Continue monitoring
			   console.log('>>>> continuing to monitor... ');
               setTimeout(function(){decisionMonitoringLoading();},2000);
             } else {
				 console.log('>>>> reloadRecommended called...');

				 //var result = [];
				 //
				 // get last decision recommendation
				 //result['before'] = getCookie("lastRecommendation");
				 // get current recommendation
				 //result['after'] = document.getElementById("decisionRecommendationTd").innerHTML;
				 //	
				 //console.log("[ " + new Date().toLocaleString() + " ] result['before']: " + result['before']);
				 //console.log("[ " + new Date().toLocaleString() + " ] result['after']: " + result['after']);
				 //
				 //if (result['before'] == 'Starter Loan Approvable' || result['after'] == 'Starter Loan Approvable'
				//	 && !(result['before'] == 'Starter Loan Approvable' && result['after'] == 'Starter Loan Approvable')) {
				//		refreshOnStarterLoan(result);
				//		reloadRecommended();	
				 //} else {
               reloadRecommended();
				 //}
			
				//setCookie("lastRecommendation", result['after'], 30);  
             }
            },{buffer: true, escape: true, timeout: 120000 , maxretries: 100}
         );
   }
   catch(err) {
   }
 }

function refreshOnStarterLoan(result) { 
  // adjusted to not refresh page--since we (and analysts don't really need to see the stip)
  // ...and it will still be visible for the funders and in the data
  
   if(result != null && result['after'] == 'Starter Loan Approvable' && result['before'] != 'Starter Loan Approvable') {
     // It is a starter loan approvable. Refresh the page instead of dynamically changing UI
    $('#processing').modal('hide');
    alert('Decision Recommendation is Starter Loan Approvable.');
    //location.reload();
  } else if (result != null && result['before'] == 'Starter Loan Approvable' && result['after'] != 'Starter Loan Approvable') {
    // It was a starter loan before and is now not one ... refresh the page because we cleared stips
    $('#processing').modal('hide');
    alert('Decision Recommendation is no longer Starter Loan Approvable.');
    //location.reload();
  }
}


//================================== Credit Scoring ============================
function scoreCreditReview(){
  showModelScoring(true);
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.recoreUpdate',
         parentId,
         function(result, event) {
			if (event.status) {
				rescoreActionFunction();
			} else {
				modelScoringError(event)
			}
		}, { timeout: 120000 }

      );
}

function reScoreCreditReview(){
  showModelScoring(true);
  Visualforce.remoting.Manager.invokeAction(
    'CreditreViewScreenController.rescoreCreditReviewRemoteAction',
         parentId,
         function(result, event) {
			if (event.status) {
				rescoreActionFunction();
			} else {
				modelScoringError(event)
			}
		}, { timeout: 120000 }

      );
}


// Hide or show the model running panel
function showModelScoring(show) {

	var modelPanel = $('.recommendId');
	var modelRunningPanel = $(".modelRunningPanel");
	if(show) {
		$('#rescore_button').hide().prop('disabled', true);
		$('#scoring_button').show().addClass('active');
		modelPanel.children().hide();
		modelRunningPanel.show();
	} else {
		// Hide the spinner. When the panel is re-rendered, the rest of the stuff will appear
		modelRunningPanel.hide();
		$('#scoring_button').hide()
        $('#rescore_button').show().prop('disabled', false);
	}
}



// Model Run Error handling functions

// Handle ajax errors
function modelScoringError(event) {
	if (event.type == 'exception') {
		if (typeof(event.xhr) != "undefined" && event.xhr.isTimeout) {
			// It's a timeout. Handle it specially
			var msg = "Scoring is taking longer than expected. Please refresh the page to check status. If this is not the first time you've received this message, please notify your Salesforce administrator.";
			handleModelRunError(msg);
			return;
		} 
	}
	if(event.message == 'The Credit Review is missing information. Please ensure Annual Revenue, FICO Score, and SIC Code are filled in before pulling again.'){
        var msg = "The Credit Review is missing information. Please ensure Annual Revenue, FICO Score, and SIC Code are filled in before pulling again.";
        handleModelRunError(msg);
        return;
	}
	// Handle like a generic error
	var msg = "A system error has occured while scoring. Please notify your Salesforce administrator.";
	handleModelRunError(msg);
}

function handleModelRunError(msg) {
	var modelPanel = $('.recommendId');
	$('#scoring_button').hide()
    $('#rescore_button').show().prop('disabled', false);
	modelPanel.children().hide();
	var error_div = modelPanel.find('.model-score-error');
	error_div.find('.error-area').html(msg);
	error_div.show();	
}