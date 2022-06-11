import "./proposal.css";

export default function build({ question, destination, data, yesCount, noCount }, id) {
  return `
    <div class="proposal">
      <div class="question"> ${question} </div>
      <div class="destination"> ${destination} </div>
      <div class="value"> ${value} </div>
      <div class="data"> ${data} </div>
      <div class="counts">
        <div class="yes-count"> Yes: ${yesCount} </div>
        <div class="no-count"> No: ${noCount} </div>
      </div>
      <div class="vote-actions">
        <div id="yes-${id}" class="button vote-yes"> Vote Yes </div>
        <div id="no-${id}" class="button vote-no"> Vote No </div>
        <div id="remove-${id}" class="button vote-remove"> Remove Vote </div>
      </div>
    </div>
  `;
}
