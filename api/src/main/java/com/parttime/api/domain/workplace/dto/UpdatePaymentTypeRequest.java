package com.parttime.api.domain.workplace.dto;

import com.parttime.api.entity.PaymentType;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class UpdatePaymentTypeRequest {

    @NotNull
    private PaymentType paymentType;
}
