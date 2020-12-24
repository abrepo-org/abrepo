import React from 'react';
import ReactDOM from 'react-dom';

export default class Img extends React.Component {

    constructor(props) {
        super(props);
        console.log("Img", this.props.renderable.screenshot);

    }

    // imgClick() {
    //     this.props.imgClickHandler(this.props.renderable.control);
    //     this.setState({bboxVisible: !this.state.bboxVisible});
    // }

    render() {

        const style = {
            outline: '1px solid #000',
            opacity: this.props.bboxVisible ? .5 : 1.0
            //filter: this.props.bboxVisible ? 'grayscale(1)' : false
        };

        console.log("IMG BBOXVISIBLE", this.props.bboxVisible);

        return(
            <img src={this.props.renderable.screenshot}
                 style={style}
                 onClick={() => this.props.imgClickHandler()}
              />
        );
    }
}
